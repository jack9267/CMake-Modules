
set(DEPENDENCIES_PATH "$ENV{jdependencies_home}" CACHE PATH "Dependencies location")

if(DEPENDENCIES_PATH STREQUAL "")
	message(FATAL_ERROR "Invalid dependencies path")
endif()

set(DEPENDENCIES_LIBS "${DEPENDENCIES_PATH}/${LIB_DIRECTORY}")

add_external_project(${DEPENDENCIES_PATH} FALSE)

find_package(SDL2 QUIET)
if(SDL2_FOUND)
	include_directories(${SDL2_INCLUDE_DIRS})
endif()
