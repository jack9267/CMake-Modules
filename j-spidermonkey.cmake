
if(SUPPORT_WINXP)
	set(SPIDERMONKEY_VERSION "52" CACHE STRING "SpiderMonkey version")
else()
	set(SPIDERMONKEY_VERSION "60" CACHE STRING "SpiderMonkey version")
endif()

set(SPIDERMONKEY_BUILD "esr${SPIDERMONKEY_VERSION}")
set(SPIDERMONKEY_LIB "mozjs-${SPIDERMONKEY_VERSION}")
set(SPIDERMONKEY_PATH "$ENV{jspidermonkey_home}" CACHE PATH "SpiderMonkey location")

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

	target_link_libraries(${NAME} PRIVATE ${SPIDERMONKEY_LIB})
endmacro()

macro(install_spidermonkey_to TO)
	if(WIN32)
		install(DIRECTORY "${SPIDERMONKEY_LIBS}/Debug/" DESTINATION "${LIB_DIRECTORY}/Debug/${TO}" CONFIGURATIONS Debug FILES_MATCHING PATTERN "*.dll" PATTERN "*.pdb" PATTERN "plc4*" EXCLUDE PATTERN "plds4*" EXCLUDE)
		install(DIRECTORY "${SPIDERMONKEY_LIBS}/Release/" DESTINATION "${LIB_DIRECTORY}/Release/${TO}" CONFIGURATIONS Release FILES_MATCHING PATTERN "*.dll" PATTERN "*.pdb" PATTERN "plc4*" EXCLUDE PATTERN "plds4*" EXCLUDE)
		install(DIRECTORY "${SPIDERMONKEY_LIBS}/Release/" DESTINATION "${LIB_DIRECTORY}/RelWithDebInfo/${TO}" CONFIGURATIONS RelWithDebInfo FILES_MATCHING PATTERN "*.dll" PATTERN "*.pdb" PATTERN "plc4*" EXCLUDE PATTERN "plds4*" EXCLUDE)
	endif()
endmacro()
