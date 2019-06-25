
# precompiled header macro
macro(precompiled_header HEADER)
	if(MSVC)
		add_compiler_flags(/Yu${HEADER}.h)
		set_source_files_properties(${HEADER}.cpp PROPERTIES COMPILE_FLAGS "/Yc${HEADER}.h")
	endif()
endmacro()

macro(set_target_precompiled_header NAME HEADER)
	if(MSVC)
		set_target_properties("${NAME}" PROPERTIES COMPILE_FLAGS "/Yu${HEADER}.h")
		set_source_files_properties(${HEADER}.cpp PROPERTIES COMPILE_FLAGS "/Yc${HEADER}.h")
	endif()
endmacro()

function(set_target_module_definition_file NAME ENGINE_DEF CONFIGURATION)
	if(MSVC)
		set(LINK_CMD "/DEF:\"${CMAKE_SOURCE_DIR}/${ENGINE_DEF}\"")

		# apply link_cmd to all release configurations
		set_target_properties("${NAME}" PROPERTIES LINK_FLAGS_${CONFIGURATION} ${LINK_CMD})
	endif()
endfunction()

macro(hide_target_symbols NAME)
	if(MSVC)
		if(CMAKE_SIZEOF_VOID_P EQUAL 8)
			set(ENGINE_DEF "${NAME}_d_x64.def")
		else()
			set(ENGINE_DEF "${NAME}_d.def")
		endif()

		set_target_module_definition_file("${NAME}" "${ENGINE_DEF}" RELEASE)
		set_target_module_definition_file("${NAME}" "${ENGINE_DEF}" MINSIZEREL)
		set_target_module_definition_file("${NAME}" "${ENGINE_DEF}" RELWITHDEBINFO)

		file(WRITE ${CMAKE_BINARY_DIR}/UpdateDEF.bat "@echo off\nif \"%2\" == \"Debug\" call \"Tools\\Lucas Easy Export Definition File Updater.exe\" \"%~1\" -update \"%~n1.def\" -silent")

		add_custom_command(TARGET "${NAME}" POST_BUILD COMMAND ${CMAKE_BINARY_DIR}/UpdateDEF.bat \"$<TARGET_FILE:${NAME}>\" $(Configuration) WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
	endif()
endmacro()

macro(install_target NAME)
	if(WIN32)
		install(TARGETS "${NAME}"
			RUNTIME DESTINATION "${LIB_DIRECTORY}/Debug" CONFIGURATIONS Debug
			LIBRARY DESTINATION "${LIB_DIRECTORY}/Debug" CONFIGURATIONS Debug
			ARCHIVE DESTINATION "${LIB_DIRECTORY}/Debug" CONFIGURATIONS Debug)
		install(TARGETS "${NAME}"
			RUNTIME DESTINATION "${LIB_DIRECTORY}/Release" CONFIGURATIONS Release
			LIBRARY DESTINATION "${LIB_DIRECTORY}/Release" CONFIGURATIONS Release
			ARCHIVE DESTINATION "${LIB_DIRECTORY}/Release" CONFIGURATIONS Release)
		install(TARGETS "${NAME}"
			RUNTIME DESTINATION "${LIB_DIRECTORY}/RelWithDebInfo" CONFIGURATIONS RelWithDebInfo
			LIBRARY DESTINATION "${LIB_DIRECTORY}/RelWithDebInfo" CONFIGURATIONS RelWithDebInfo
			ARCHIVE DESTINATION "${LIB_DIRECTORY}/RelWithDebInfo" CONFIGURATIONS RelWithDebInfo)
	else()
		install(TARGETS "${NAME}"
			RUNTIME DESTINATION "${LIB_DIRECTORY}"
			LIBRARY DESTINATION "${LIB_DIRECTORY}"
			ARCHIVE DESTINATION "${LIB_DIRECTORY}")
	endif()
endmacro()

macro(install_target_to NAME TO)
	if(WIN32)
		install(TARGETS "${NAME}"
			RUNTIME DESTINATION "${LIB_DIRECTORY}/Debug/${TO}" CONFIGURATIONS Debug
			LIBRARY DESTINATION "${LIB_DIRECTORY}/Debug/${TO}" CONFIGURATIONS Debug
			ARCHIVE DESTINATION "${LIB_DIRECTORY}/Debug/${TO}" CONFIGURATIONS Debug)
		install(TARGETS "${NAME}"
			RUNTIME DESTINATION "${LIB_DIRECTORY}/Release/${TO}" CONFIGURATIONS Release
			LIBRARY DESTINATION "${LIB_DIRECTORY}/Release/${TO}" CONFIGURATIONS Release
			ARCHIVE DESTINATION "${LIB_DIRECTORY}/Release/${TO}" CONFIGURATIONS Release)
		install(TARGETS "${NAME}"
			RUNTIME DESTINATION "${LIB_DIRECTORY}/RelWithDebInfo/${TO}" CONFIGURATIONS RelWithDebInfo
			LIBRARY DESTINATION "${LIB_DIRECTORY}/RelWithDebInfo/${TO}" CONFIGURATIONS RelWithDebInfo
			ARCHIVE DESTINATION "${LIB_DIRECTORY}/RelWithDebInfo/${TO}" CONFIGURATIONS RelWithDebInfo)
	else()
		install(TARGETS "${NAME}"
			RUNTIME DESTINATION "${LIB_DIRECTORY}/${TO}"
			LIBRARY DESTINATION "${LIB_DIRECTORY}/${TO}"
			ARCHIVE DESTINATION "${LIB_DIRECTORY}/${TO}")
	endif()
endmacro()

macro(install_target_debug_info NAME)
	if(MSVC)
		install(FILES $<TARGET_PDB_FILE:${NAME}> DESTINATION "${LIB_DIRECTORY}/Debug" CONFIGURATIONS Debug OPTIONAL)
		install(FILES $<TARGET_PDB_FILE:${NAME}> DESTINATION "${LIB_DIRECTORY}/Release" CONFIGURATIONS Release OPTIONAL)
		install(FILES $<TARGET_PDB_FILE:${NAME}> DESTINATION "${LIB_DIRECTORY}/RelWithDebInfo" CONFIGURATIONS RelWithDebInfo OPTIONAL)
	endif()
endmacro()

macro(install_target_debug_info_to NAME TO)
	if(MSVC)
		install(FILES $<TARGET_PDB_FILE:${NAME}> DESTINATION "${LIB_DIRECTORY}/Debug/${TO}" CONFIGURATIONS Debug OPTIONAL)
		install(FILES $<TARGET_PDB_FILE:${NAME}> DESTINATION "${LIB_DIRECTORY}/Release/${TO}" CONFIGURATIONS Release OPTIONAL)
		install(FILES $<TARGET_PDB_FILE:${NAME}> DESTINATION "${LIB_DIRECTORY}/RelWithDebInfo/${TO}" CONFIGURATIONS RelWithDebInfo OPTIONAL)
	endif()
endmacro()

# to avoid repeating stuff
function(new_library_static NAME SOURCES DEFINES)
	set(LIBRARY_SOURCES "")
	foreach(SOURCE ${SOURCES})
		list(APPEND LIBRARY_SOURCES ${SOURCE})
	endforeach()

	add_library("${NAME}_static" STATIC ${LIBRARY_SOURCES})

	if(MSVC AND EMBEDDED_PDB)
		# embedd pdb
		set_target_properties("${NAME}_static" PROPERTIES COMPILE_OPTIONS "/Z7")
	endif()

	foreach(DEFINE ${DEFINES})
		target_compile_definitions("${NAME}_static" PRIVATE ${DEFINE})
	endforeach()

	install_target(${NAME}_static)
endfunction()

function(new_library_shared NAME SOURCES DEFINES)
	set(LIBRARY_SOURCES "")
	foreach(SOURCE ${SOURCES})
		list(APPEND LIBRARY_SOURCES ${SOURCE})
	endforeach()

	add_library("${NAME}" SHARED ${LIBRARY_SOURCES})

	set_target_properties("${NAME}" PROPERTIES RUNTIME_OUTPUT_NAME "${NAME}${RUNTIME_RELEASE_POSTFIX}")
	set_target_properties("${NAME}" PROPERTIES RUNTIME_OUTPUT_NAME_DEBUG "${NAME}${RUNTIME_DEBUG_POSTFIX}")

	foreach(DEFINE ${DEFINES})
		target_compile_definitions("${NAME}" PRIVATE ${DEFINE})
	endforeach()

	install_target(${NAME})
	install_target_debug_info("${NAME}")
endfunction()

function(new_library_executable NAME SOURCES DEFINES)
	set(LIBRARY_SOURCES "")
	foreach(SOURCE ${SOURCES})
		list(APPEND LIBRARY_SOURCES ${SOURCE})
	endforeach()

	add_executable("${NAME}" ${LIBRARY_SOURCES})

	set_target_properties("${NAME}" PROPERTIES RUNTIME_OUTPUT_NAME "${NAME}${RUNTIME_RELEASE_POSTFIX}")
	set_target_properties("${NAME}" PROPERTIES RUNTIME_OUTPUT_NAME_DEBUG "${NAME}${RUNTIME_DEBUG_POSTFIX}")

	foreach(DEFINE ${DEFINES})
		target_compile_definitions("${NAME}" PRIVATE ${DEFINE})
	endforeach()

	install_target(${NAME})
	install_target_debug_info(${NAME})
endfunction()

macro(copy_dependency_to PATH NAME EXTENSION TO)
	install(DIRECTORY "${PATH}/Debug/" DESTINATION "${LIB_DIRECTORY}/Debug/${TO}" CONFIGURATIONS Debug FILES_MATCHING PATTERN "${NAME}${RUNTIME_DEBUG_POSTFIX}.${EXTENSION}")
	install(DIRECTORY "${PATH}/Release/" DESTINATION "${LIB_DIRECTORY}/Release/${TO}" CONFIGURATIONS Release FILES_MATCHING PATTERN "${NAME}${RUNTIME_RELEASE_POSTFIX}.${EXTENSION}")
	if(EXISTS "${PATH}/RelWithDebInfo")
		install(DIRECTORY "${PATH}/RelWithDebInfo/" DESTINATION "${LIB_DIRECTORY}/RelWithDebInfo/${TO}" CONFIGURATIONS RelWithDebInfo FILES_MATCHING PATTERN "${NAME}${RUNTIME_RELEASE_POSTFIX}.${EXTENSION}")
	else()
		install(DIRECTORY "${PATH}/Release/" DESTINATION "${LIB_DIRECTORY}/RelWithDebInfo/${TO}" CONFIGURATIONS RelWithDebInfo FILES_MATCHING PATTERN "${NAME}${RUNTIME_RELEASE_POSTFIX}.${EXTENSION}")
	endif()
endmacro()

macro(copy_dependency PATH NAME EXTENSION)
	#add_custom_command(TARGET ${TARGET_NAME} POST_BUILD COMMAND copy \"${PATH}\\$<$<CONFIG:Debug>:Debug>$<$<NOT:$<CONFIG:Debug>>:Release>\\${NAME}$<$<CONFIG:Debug>:${RUNTIME_DEBUG_POSTFIX}>.dll\" \"$<TARGET_FILE_DIR:${TARGET_NAME}>\" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})

	install(DIRECTORY "${PATH}/Debug/" DESTINATION "${LIB_DIRECTORY}/Debug" CONFIGURATIONS Debug FILES_MATCHING PATTERN "${NAME}${RUNTIME_DEBUG_POSTFIX}.${EXTENSION}")
	install(DIRECTORY "${PATH}/Release/" DESTINATION "${LIB_DIRECTORY}/Release" CONFIGURATIONS Release FILES_MATCHING PATTERN "${NAME}${RUNTIME_RELEASE_POSTFIX}.${EXTENSION}")
	if(EXISTS "${PATH}/RelWithDebInfo")
		install(DIRECTORY "${PATH}/RelWithDebInfo/" DESTINATION "${LIB_DIRECTORY}/RelWithDebInfo" CONFIGURATIONS RelWithDebInfo FILES_MATCHING PATTERN "${NAME}${RUNTIME_RELEASE_POSTFIX}.${EXTENSION}")
	else()
		install(DIRECTORY "${PATH}/Release/" DESTINATION "${LIB_DIRECTORY}/RelWithDebInfo" CONFIGURATIONS RelWithDebInfo FILES_MATCHING PATTERN "${NAME}${RUNTIME_RELEASE_POSTFIX}.${EXTENSION}")
	endif()
endmacro()

macro(disable_rtti)
	if(MSVC)
		# disable RTTI
		add_compiler_flags(/GR-)
	endif()
endmacro()

macro(get_git_info)
	# Get the current working branch
	execute_process(
	  COMMAND git rev-parse --abbrev-ref HEAD
	  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
	  OUTPUT_VARIABLE GIT_BRANCH
	  OUTPUT_STRIP_TRAILING_WHITESPACE
	)

	# Get the latest abbreviated commit hash of the working branch
	execute_process(
	  COMMAND git log -1 --format=%h
	  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
	  OUTPUT_VARIABLE GIT_COMMIT_HASH
	  OUTPUT_STRIP_TRAILING_WHITESPACE
	)
endmacro()

macro(group_sources SOURCES DIRS)
	if(MSVC)
		foreach(FILE ${SOURCES})
		    # Get the directory of the source file
		    get_filename_component(PARENT_DIR "${FILE}" DIRECTORY)

		    set(GROUP ${PARENT_DIR})

		    # Remove common directory prefix to make the group
		    foreach(DIR ${DIRS})
		    	string(REPLACE "${DIR}" "" GROUP "${GROUP}")
		    endforeach()

		    # Make sure we are using windows slashes
		    string(REPLACE "/" "\\" GROUP "${GROUP}")

		    # Group into "Source Files" and "Header Files"
		    if ("${FILE}" MATCHES ".*\\.(cpp|CPP)")
		       set(GROUP "Source Files\\${GROUP}")
		    elseif("${FILE}" MATCHES ".*\\.(h|H)")
		       set(GROUP "Header Files\\${GROUP}")
		    elseif("${FILE}" MATCHES ".*\\.(rc|RC)")
		       set(GROUP "Resource Files\\${GROUP}")
		    endif()

		    source_group("${GROUP}" FILES "${FILE}")
		endforeach()
	endif()
endmacro()
