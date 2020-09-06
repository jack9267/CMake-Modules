
set(GALACTIC_PATH "$ENV{galactic_home}" CACHE PATH "Galactic location")

if(NOT EXISTS "${GALACTIC_PATH}")
	message(FATAL_ERROR "Invalid Galactic path")
endif()

set(GALACTIC_LIBS "${GALACTIC_PATH}/${LIB_DIRECTORY}")

add_external_project(${GALACTIC_PATH} TRUE)
