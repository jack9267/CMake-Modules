
if(WIN32)
	set(DEPENDENCIES_PATH "$ENV{jdependencies_home}" CACHE PATH "Dependencies location")

	if(DEPENDENCIES_PATH STREQUAL "")
		message(FATAL_ERROR "Invalid dependencies path")
	endif()

	add_external_project(${DEPENDENCIES_PATH} FALSE)
else()
	find_package(SDL2 REQUIRED)

	include_directories(${SDL2_INCLUDE_DIRS})
endif()
