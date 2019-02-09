if(EXISTS "$ENV{dropbox}/Private/Certificate/Output/Code.pfx")
	set(ENGINE_SIGNING ON)
else()
	set(ENGINE_SIGNING OFF)
endif()

macro(sign_me NAME)
	if(MSVC AND ENGINE_SIGNING)
		file(WRITE ${CMAKE_BINARY_DIR}/SignMe.bat "@echo off\n\"%ProgramFiles(x86)%\\Microsoft SDKs\\Windows\\v7.1A\\Bin\\signtool\" sign /v /f \"%dropbox%\\Private\\Certificate\\Output\\Code.pfx\" /fd SHA256 \"%~1\"")

		add_custom_command(TARGET ${NAME} POST_BUILD COMMAND ${CMAKE_BINARY_DIR}/SignMe.bat \"$<TARGET_FILE:${NAME}>\" $(Configuration) WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
	endif()
endmacro()
