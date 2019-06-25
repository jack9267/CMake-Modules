
set(SPIDERMONKEY_PATH "${CMAKE_SOURCE_DIR}/../SpiderMonkey" CACHE PATH "SpiderMonkey location")
include_directories("${SPIDERMONKEY_PATH}/include")

if(WIN32)
	set(SPIDERMONKEY_LIBS "${SPIDERMONKEY_PATH}/Lib/${ENGINE_PLATFORM}/v140_xp")
endif()

if(MSVC)
	set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "${CMAKE_SHARED_LINKER_FLAGS_DEBUG} /LIBPATH:\"${SPIDERMONKEY_LIBS}/Debug\"")
	set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE} /LIBPATH:\"${SPIDERMONKEY_LIBS}/Release\"")
	set(CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO "${CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO} /LIBPATH:\"${SPIDERMONKEY_LIBS}/Release\"")

	set(CMAKE_EXE_LINKER_FLAGS_DEBUG "${CMAKE_SHARED_LINKER_FLAGS_DEBUG} /LIBPATH:\"${SPIDERMONKEY_LIBS}/Debug\"")
	set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE} /LIBPATH:\"${SPIDERMONKEY_LIBS}/Release\"")
	set(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO "${CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO} /LIBPATH:\"${SPIDERMONKEY_LIBS}/Release\"")
endif()
