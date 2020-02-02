
find_package(WindowsSDK COMPONENTS tools REQUIRED)

include_directories("${WINDOWSSDK_LATEST_DIR}/Include/10.0.18362.0/um")
include_directories("${WINDOWSSDK_LATEST_DIR}/Include/10.0.18362.0/shared")
include_directories("${WINDOWSSDK_LATEST_DIR}/Include/10.0.18362.0/winrt")
