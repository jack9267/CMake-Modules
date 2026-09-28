# Targeting Windows XP from a current toolset, not only v141_xp. Two pieces make that possible:
#   VC-LTL5     links Windows' own msvcrt.dll as the CRT (never calls FlsAlloc)
#   YY-Thunks   an object defining the __imp__ symbols for Win32 APIs XP lacks
# So SUPPORT_WINXP (the output runs on XP) and USING_XP_TOOLSET (the build uses v141_xp) differ:
#   vendor/WindowsSDK-xp-shim   USING_XP_TOOLSET  only that SDK lacks VersionHelpers.h etc.
#   /Zc:threadSafeInit-         SUPPORT_WINXP     magic statics break in a LoadLibrary'd DLL on XP
#   SpiderMonkey 52 vs 60       SUPPORT_WINXP
#   this file                   both              v141_xp needs none of it

if(MSVC AND CMAKE_VS_PLATFORM_TOOLSET MATCHES ".*_xp$")
	set(USING_XP_TOOLSET true)
else()
	set(USING_XP_TOOLSET false)
endif()

# Defaults to the old derived value, so the vs2017-xp/vs2019-xp presets are unchanged.
option(SUPPORT_WINXP "Produce binaries that run on Windows XP" ${USING_XP_TOOLSET})

# Separate from SUPPORT_WINXP since it swaps every binary's CRT. Useful off XP too: nothing to
# redistribute, and ~130 KB smaller per binary than the static CRT.
option(USE_MSVCRT "Link Windows' own msvcrt.dll as the CRT, through VC-LTL5" OFF)

# XP's loader never patches a LoadLibrary'd module's _tls_index, breaking its thread_local. Off:
# ModLauncher's DynamicTLSFixup.h fixes that at load, and Galactic has no thread_local. Replaces
# the DLL's entry point.
option(USE_YY_THUNKS_TLS "Let YY-Thunks initialise a DLL's own TLS on XP" OFF)

set(USE_VC_LTL false)
set(USE_YY_THUNKS false)

# The two are independent: the stock v143 CRT's own FlsAlloc call binds to the thunks too, since an
# object on the link line always wins over kernel32.lib. Both paths have run on XP (5.1.2600):
# msvcrt through TRLE's ThunksTest, the static UCRT through gpakviewer.

if(USE_MSVCRT AND MSVC)
	# Global and before any target: it swaps the CRT by prepending its own include/lib directories.
	set(VC_LTL_ROOT_PATH "$ENV{VC_LTL_Root}" CACHE PATH "VC-LTL5 location")

	if(EXISTS "${VC_LTL_ROOT_PATH}/VC-LTL helper for cmake.cmake")
		# Pinned, so the helper's own search cannot find a stray copy.
		set(VC_LTL_Root "${VC_LTL_ROOT_PATH}")

		# true targets 5.1.2600.0 (5.2.3790.0 on x64); false lets VC-LTL default to 6.0.6000.0.
		if(SUPPORT_WINXP)
			set(SupportWinXP "true")
		else()
			set(SupportWinXP "false")
		endif()

		include("${VC_LTL_ROOT_PATH}/VC-LTL helper for cmake.cmake")
		set(USE_VC_LTL true)
	else()
		message(FATAL_ERROR
			"USE_MSVCRT needs VC-LTL5, and VC_LTL_Root does not point at it "
			"(${VC_LTL_ROOT_PATH}). Extract VC-LTL-Binary.7z from "
			"https://github.com/Chuyu-Team/VC-LTL5/releases and set VC_LTL_Root to it.")
	endif()
endif()

# The Win32 APIs, separate from the CRT, so this follows SUPPORT_WINXP. Applied per target.
if(SUPPORT_WINXP AND MSVC AND NOT USING_XP_TOOLSET)
	set(YY_THUNKS_ROOT_PATH "$ENV{YY_Thunks_Root}" CACHE PATH "YY-Thunks location")
	set(YY_THUNKS_OBJ "${YY_THUNKS_ROOT_PATH}/objs/${ENGINE_PLATFORM}/YY_Thunks_for_WinXP.obj")

	if(EXISTS "${YY_THUNKS_OBJ}")
		set(USE_YY_THUNKS true)
	else()
		message(FATAL_ERROR
			"SUPPORT_WINXP needs YY-Thunks on a non-XP toolset, and ${YY_THUNKS_OBJ} is not there. "
			"Extract YY-Thunks-Objs.zip from https://github.com/Chuyu-Team/YY-Thunks/releases and "
			"set YY_Thunks_Root to it.")
	endif()
endif()

# Not for static libraries: whatever links them pulls the object in, and twice collides.
function(apply_xp_thunks NAME)
	if(NOT USE_YY_THUNKS)
		return()
	endif()

	get_target_property(TARGET_KIND ${NAME} TYPE)

	# A generator expression, since several targets set WIN32_EXECUTABLE after
	# new_library_executable - read here, they would link CONSOLE and fail on _main.
	if(TARGET_KIND STREQUAL "EXECUTABLE")
		set(SUBSYSTEM "$<IF:$<BOOL:$<TARGET_PROPERTY:WIN32_EXECUTABLE>>,WINDOWS,CONSOLE>")
	else()
		set(SUBSYSTEM "WINDOWS")
	endif()

	# XP x64 reports itself as 5.2.
	if(CMAKE_SIZEOF_VOID_P EQUAL 8)
		set(SUBSYSTEM_VERSION "5.02")
	else()
		set(SUBSYSTEM_VERSION "5.01")
	endif()

	target_link_options(${NAME} PRIVATE
		"${YY_THUNKS_OBJ}"

		# v143 emits 6.00, which XP refuses to load.
		"/SUBSYSTEM:${SUBSYSTEM},${SUBSYSTEM_VERSION}"

		# Repeated for Debug, where j-common does not set it: the object references ~1100 APIs. A
		# Debug gpakviewer without it: 24 imported DLLs instead of 9 (ESENT, WINHTTP, ...), 3.6 MB
		# instead of 1.6. It still ran on XP SP3, so this is size and startup, not loadability.
		"/OPT:REF"

		# /OPT:REF is incompatible with incremental linking (LNK4075). Measured cost on that same
		# target: under 0.1s per one-file rebuild.
		"/INCREMENTAL:NO"

		# LNK4075 from VC-LTL's prebuilt objects, built with /EDITANDCONTINUE.
		"/ignore:4075")

	# DLLs only; the loader handles an executable's TLS. The alternatename passes on the CRT entry
	# point it replaces (decorated on x86).
	if(USE_YY_THUNKS_TLS AND TARGET_KIND STREQUAL "SHARED_LIBRARY")
		if(CMAKE_SIZEOF_VOID_P EQUAL 8)
			set(YY_TLS_ALIAS "YY_ThunksOriginalDllMainCRTStartup=_DllMainCRTStartup")
		else()
			set(YY_TLS_ALIAS "_YY_ThunksOriginalDllMainCRTStartup@12=__DllMainCRTStartup@12")
		endif()

		target_link_options(${NAME} PRIVATE
			"/ENTRY:DllMainCRTStartupForYY_Thunks"
			"/alternatename:${YY_TLS_ALIAS}")
	endif()
endfunction()
