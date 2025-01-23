
if(MSVC AND CUSTOM_MSVC_WARNING_LEVEL)
	# Force to always compile with W4
	if(CMAKE_CXX_FLAGS MATCHES "/W[0-4]")
		string(REGEX REPLACE "/W[0-4]" "/W${CUSTOM_MSVC_WARNING_LEVEL}" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
	else()
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W${CUSTOM_MSVC_WARNING_LEVEL}")
	endif()
endif()

if(MSVC)
	# 'identifier' : unreferenced formal parameter
	disable_warning(4100)

	# Inline asm assigning to 'FS:0' : handler not registered as safe handler
	disable_warning(4733)

	# identifier' : class 'type' needs to have dll-interface to be used by clients of class 'type2'
	disable_warning(4251)

	# export 'exportname' specified multiple times; using first specification
	disable_linker_warning(4197)
endif()
