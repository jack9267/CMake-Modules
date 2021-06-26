cmake_minimum_required(VERSION 3.15)

# Currently we put the runtime library as flags
cmake_policy(SET CMP0091 OLD)

# Do not add flags to export symbols from executables without the ENABLE_EXPORTS target property
cmake_policy(SET CMP0065 NEW)

# We only want Debug and Release
#set(CMAKE_CONFIGURATION_TYPES "Debug;Release;RelWithDebInfo" CACHE STRING "Configuration types" FORCE)

# link time generation
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE TRUE)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELWITHDEBINFO TRUE)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_MINSIZEREL TRUE)

if(NOT MSVC)
	# Use pthreads on other systems
	set(CMAKE_THREAD_PREFER_PTHREAD true)
endif()

if(MSVC)
	# Ensure Release has debug info
	#set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELWITHDEBINFO}")
	#set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")

	# Enable PDB on all configurations
	set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /Zi")
	set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /Zi")

	set(CMAKE_C_FLAGS_MINSIZEREL "${CMAKE_C_FLAGS_MINSIZEREL} /Zi")
	set(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS_MINSIZEREL} /Zi")

	# change it so subsystem is set to windows for DLL files as this is default in Visual Studio
	set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /SUBSYSTEM:WINDOWS")

	set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE} /debug")
	set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE} /debug")

	set(CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL "${CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL} /debug")
	set(CMAKE_EXE_LINKER_FLAGS_MINSIZEREL "${CMAKE_EXE_LINKER_FLAGS_MINSIZEREL} /debug")

	# Enable asserts in release
	string(REPLACE "/DNDEBUG" "" CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")
	string(REPLACE "/DNDEBUG" "" CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")
	string(REPLACE "/DNDEBUG" "" CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS_MINSIZEREL}")
endif()

# C++ standard
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED OFF)
set(CMAKE_CXX_EXTENSIONS OFF)

set(RUNTIME_DEBUG_POSTFIX "_d")
set(RUNTIME_RELEASE_POSTFIX "")

# determine bits
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
	set(ENGINE_PLATFORM "x64")

	# on Windows use _x64 for 64-bit binaries
	if(WIN32)
		set(RUNTIME_DEBUG_POSTFIX "_d_${ENGINE_PLATFORM}")
		set(RUNTIME_RELEASE_POSTFIX "_${ENGINE_PLATFORM}")
	endif()
else()
	set(ENGINE_PLATFORM "x86")
endif()

# lib directory
if(MSVC)
	set(LIB_DIRECTORY "Lib/${ENGINE_PLATFORM}/${CMAKE_VS_PLATFORM_TOOLSET}")
else()
	set(LIB_DIRECTORY "Lib/${ENGINE_PLATFORM}")
endif()

# hide symbols
set(CMAKE_CXX_VISIBILITY_PRESET hidden)

# hide symbols on unix
if(UNIX AND CMAKE_COMPILER_IS_GNUCC)
	set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3 -fvisibility=hidden -fdata-sections -ffunction-sections -g0")
	set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -O3 -fvisibility=hidden -fdata-sections -ffunction-sections -g0")

	set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE} -Wl,--gc-sections")
endif()

macro(add_compiler_flags FLAGS)
	foreach(FLAG ${FLAGS})
		set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${FLAG}")
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${FLAG}")
	endforeach()
endmacro()

macro(compiler_flags CONFIGURATIONS FLAGS)
	foreach(CONFIGURATION ${CONFIGURATIONS})
		foreach(FLAG ${FLAGS})
			set(CMAKE_C_FLAGS_${CONFIGURATION} "${CMAKE_C_FLAGS_${CONFIGURATION}} ${FLAG}")
			set(CMAKE_CXX_FLAGS_${CONFIGURATION} "${CMAKE_CXX_FLAGS_${CONFIGURATION}} ${FLAG}")
		endforeach()
	endforeach()
endmacro()

macro(linker_flags TYPES CONFIGURATIONS FLAGS)
	foreach(CONFIGURATION ${CONFIGURATIONS})
		foreach(TYPE ${TYPES})
			set(CMAKE_${TYPE}_LINKER_FLAGS_${CONFIGURATION} "${CMAKE_${TYPE}_LINKER_FLAGS_${CONFIGURATION}} ${FLAGS}")
		endforeach()
	endforeach()
endmacro()

macro(define CONFIGURATION DEFINES)
	foreach(DEFINE ${DEFINES})
		set(CMAKE_C_FLAGS_${CONFIGURATION} "${CMAKE_C_FLAGS_${CONFIGURATION}} -D${DEFINE}")
		set(CMAKE_CXX_FLAGS_${CONFIGURATION} "${CMAKE_CXX_FLAGS_${CONFIGURATION}} -D${DEFINE}")
	endforeach()
endmacro()

macro(define_debug DEFINES)
	define(DEBUG ${DEFINES})
endmacro()

# Enable DEBUG=1 for debug builds as some projects check that
define_debug(DEBUG=1)

# Visual Studio specifics
if(MSVC)
	# Force /MT for static VC runtimes if Release...
	option(FORCE_STATIC_VCRT "Force /MT for static VC runtimes" OFF)
	if(FORCE_STATIC_VCRT)
		foreach(flag_var
			CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE
			CMAKE_C_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO
			CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE
			CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_RELWITHDEBINFO)
			if(${flag_var} MATCHES "/MD")
				string(REGEX REPLACE "/MD" "/MT" ${flag_var} "${${flag_var}}")
			endif()
		endforeach()

		set(LIB_DIRECTORY "${LIB_DIRECTORY}_static")
	endif()

	if(MSVC_VERSION GREATER_EQUAL 1900 AND CMAKE_SIZEOF_VOID_P EQUAL 4)
		option(NO_ENHANCED_INSTRUCTIONS "No Enhanced Instructions" OFF)
		if(NO_ENHANCED_INSTRUCTIONS)
			# No Enhanced Instructions
			add_compiler_flags(/arch:IA32)
		endif()
	endif()

	# common defines
	add_definitions(-DWIN32 -D_WINDOWS -D_CRT_SECURE_NO_DEPRECATE -D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_WARNINGS -D_USE_MATH_DEFINES=1 -DNOMINMAX)

	if(MSVC_VERSION GREATER_EQUAL 1900)
		# Prevent static variables from being thread local storage
		add_compiler_flags("/Zc:threadSafeInit-")
	endif()

	# multi-processor core
	add_compiler_flags("/MP")

	# smaller binary in release
	compiler_flags("RELEASE" "/O1 /Ob2")

	# whole program optimisation
	compiler_flags("RELEASE;RELWITHDEBINFO;MINSIZEREL" "/GL /Oi")

	foreach(flag_var
		CMAKE_SHARED_LINKER_FLAGS_RELEASE
		CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO
		CMAKE_EXE_LINKER_FLAGS_RELEASE
		CMAKE_EXE_LINKER_FLAGS_MINSIZEREL CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO)
		if(${flag_var} MATCHES "/INCREMENTAL" AND NOT ${flag_var} MATCHES "/INCREMENTAL:NO")
			string(REGEX REPLACE "/INCREMENTAL" "/INCREMENTAL:NO" ${flag_var} "${${flag_var}}")
		endif()
	endforeach()

	linker_flags("SHARED;STATIC;EXE" "RELEASE;RELWITHDEBINFO;MINSIZEREL" "/LTCG")
	linker_flags("SHARED;EXE" "RELEASE;RELWITHDEBINFO;MINSIZEREL" "/OPT:REF")

	# disable manifest on dlls
	set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /MANIFEST:NO")

	# macro to disable VS warning
	macro(disable_warning ID)
		add_compiler_flags(/wd${ID})
	endmacro()

	# macro to disable VS linker warnings
	macro(disable_linker_warning ID)
		set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /ignore:${ID}")
		set(CMAKE_STATIC_LINKER_FLAGS "${CMAKE_STATIC_LINKER_FLAGS} /ignore:${ID}")
		set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /ignore:${ID}")
	endmacro()

	# This object file does not define any previously undefined public symbols, so it will not be used by any link operation that consumes this library
	disable_linker_warning(4221)

	# Warnings should be errors
	#add_compiler_flags("/WX")
endif()

if(UNIX)
	# Disable deprecated warnings because of unnamed unions
	add_compiler_flags("-Wno-deprecated-declarations")
endif()

# to avoid repeating stuff
function(install_include INCLUDE)
	install(DIRECTORY "${INCLUDE}/" DESTINATION include FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp")
endfunction()

# for raspberry pi we need these, dont ask why
if(UNIX AND NOT APPLE AND NOT ANDROID)
	if(EXISTS "/opt/vc/include/bcm_host.h")
		include_directories(/opt/vc/include /opt/vc/include/interface/vcos/pthreads /opt/vc/include/interface/vmcs_host/linux)
		link_directories(/opt/vc/lib)
		link_libraries(openmaxil bcm_host vcos vchiq_arm)
	endif()
endif()
