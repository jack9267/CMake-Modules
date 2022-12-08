
if(SUPPORT_WINXP)
	set(SPIDERMONKEY_BUILD "esr52")
else()
	set(SPIDERMONKEY_BUILD "esr60")
endif()

set(SPIDERMONKEY_PATH "${CMAKE_SOURCE_DIR}/../SpiderMonkey" CACHE PATH "SpiderMonkey location")

if(NOT EXISTS "${SPIDERMONKEY_PATH}")
	message(FATAL_ERROR "Invalid SpiderMonkey path")
endif()

set(SPIDERMONKEY_LIBS "${SPIDERMONKEY_PATH}/${SPIDERMONKEY_BUILD}/Lib/${ENGINE_PLATFORM}")

include_directories("${SPIDERMONKEY_PATH}/${SPIDERMONKEY_BUILD}/include")

add_external_project_internal(${SPIDERMONKEY_LIBS} FALSE)

macro(target_link_spidermonkey NAME)
	if(WIN32)
		target_link_libraries(${NAME} PRIVATE kernel32)
	endif()

	if(SUPPORT_WINXP)
		target_link_libraries(${NAME} PRIVATE mozjs-52)
	else()
		target_link_libraries(${NAME} PRIVATE mozjs-60)
	endif()
endmacro()

macro(install_spidermonkey_to TO)
	if(WIN32)
		install(DIRECTORY "${SPIDERMONKEY_LIBS}/Debug/" DESTINATION "${LIB_DIRECTORY}/Debug/${TO}" CONFIGURATIONS Debug FILES_MATCHING PATTERN "*.dll" PATTERN "*.pdb" PATTERN "plc4*" EXCLUDE PATTERN "plds4*" EXCLUDE)
		install(DIRECTORY "${SPIDERMONKEY_LIBS}/Release/" DESTINATION "${LIB_DIRECTORY}/Release/${TO}" CONFIGURATIONS Release FILES_MATCHING PATTERN "*.dll" PATTERN "*.pdb" PATTERN "plc4*" EXCLUDE PATTERN "plds4*" EXCLUDE)
		install(DIRECTORY "${SPIDERMONKEY_LIBS}/Release/" DESTINATION "${LIB_DIRECTORY}/RelWithDebInfo/${TO}" CONFIGURATIONS RelWithDebInfo FILES_MATCHING PATTERN "*.dll" PATTERN "*.pdb" PATTERN "plc4*" EXCLUDE PATTERN "plds4*" EXCLUDE)
	endif()
endmacro()
