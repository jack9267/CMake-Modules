
if(MSVC)
	# Force to always compile with W4
	if(CMAKE_CXX_FLAGS MATCHES "/W[0-4]")
		string(REGEX REPLACE "/W[0-4]" "/W4" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
	else()
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W4")
	endif()
endif()

if(MSVC)
	# nonstandard extension used : nameless struct/union
	disable_warning(4201)

	# 'identifier' : unreferenced formal parameter
	disable_warning(4100)

	# conditional expression is constant
	disable_warning(4127)

	# nonstandard extension used : class rvalue used as lvalue
	disable_warning(4238)

	# Potentially uninitialized local variable 'name' used
	disable_warning(4701)

	# Potentially uninitialized local pointer variable 'name' used
	disable_warning(4703)

	# 'identifier' : local variable is initialized but not referenced
	disable_warning(4189)

	# cast truncates constant value
	disable_warning(4310)

	# interaction between 'function' and C++ object destruction is non-portable
	disable_warning(4611)

	# Inline asm assigning to 'FS:0' : handler not registered as safe handler
	disable_warning(4733)

	# identifier' : class 'type' needs to have dll-interface to be used by clients of class 'type2'
	disable_warning(4251)

	# structure was padded due to alignment specifier
	disable_warning(4324)

	# export 'exportname' specified multiple times; using first specification
	disable_linker_warning(4197)
endif()
