
# precompiled header macro
macro(precompiled_header HEADER)
	add_compiler_flags(/Yu${HEADER}.h)
	set_source_files_properties(${HEADER}.cpp PROPERTIES COMPILE_FLAGS "/Yc${HEADER}.h")
endmacro()

macro(set_target_precompiled_header NAME HEADER)
	set_target_properties("${NAME}" PROPERTIES COMPILE_FLAGS "/Yu${HEADER}.h.h")
	set_source_files_properties(${HEADER}.cpp PROPERTIES COMPILE_FLAGS "/Yc${HEADER}.h")
endmacro()

macro(install_target NAME)
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
endmacro()

macro(install_target_debug_info NAME)
	if(MSVC)
		install(FILES $<TARGET_PDB_FILE:${NAME}> DESTINATION "${LIB_DIRECTORY}/Debug" CONFIGURATIONS Debug OPTIONAL)
		install(FILES $<TARGET_PDB_FILE:${NAME}> DESTINATION "${LIB_DIRECTORY}/Release" CONFIGURATIONS Release OPTIONAL)
		install(FILES $<TARGET_PDB_FILE:${NAME}> DESTINATION "${LIB_DIRECTORY}/RelWithDebInfo" CONFIGURATIONS RelWithDebInfo OPTIONAL)
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

macro(copy_dependency PATH NAME EXTENSION)
	#add_custom_command(TARGET ${TARGET_NAME} POST_BUILD COMMAND copy \"${PATH}\\$<$<CONFIG:Debug>:Debug>$<$<NOT:$<CONFIG:Debug>>:Release>\\${NAME}$<$<CONFIG:Debug>:${RUNTIME_DEBUG_POSTFIX}>.dll\" \"$<TARGET_FILE_DIR:${TARGET_NAME}>\" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})

	install(DIRECTORY "${PATH}/Debug/" DESTINATION "${LIB_DIRECTORY}/Debug" CONFIGURATIONS Debug FILES_MATCHING PATTERN "${NAME}${RUNTIME_DEBUG_POSTFIX}.${EXTENSION}")
	install(DIRECTORY "${PATH}/Release/" DESTINATION "${LIB_DIRECTORY}/Release" CONFIGURATIONS Release FILES_MATCHING PATTERN "${NAME}${RUNTIME_RELEASE_POSTFIX}.${EXTENSION}")
	install(DIRECTORY "${PATH}/Release/" DESTINATION "${LIB_DIRECTORY}/RelWithDebInfo" CONFIGURATIONS RelWithDebInfo FILES_MATCHING PATTERN "${NAME}${RUNTIME_RELEASE_POSTFIX}.${EXTENSION}")
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
