
if(WIN32)
	set(LITEHTML_PATH "$ENV{jlitehtml_home}" CACHE PATH "Litehtml location")

	if(LITEHTML_PATH STREQUAL "")
		message(FATAL_ERROR "Invalid litehtml path")
	endif()
endif()

add_external_project(${LITEHTML_PATH} FALSE)
