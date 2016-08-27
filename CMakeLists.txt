cmake_minimum_required(VERSION 2.8)
project(bridge)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")
find_package(Qt5 COMPONENTS Core Gui Qml Quick REQUIRED)
include_directories(${CMAKE_BINARY_DIR})
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14 -Wall -Wextra")
set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

if(CMAKE_BUILD_TYPE STREQUAL "" OR CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2 -Werror")
endif()

set(SOURCES
 main.cxx
)

set(QOBJECT_HEADERS
)
qt5_wrap_cpp(MOC_SOURCES ${QOBJECT_HEADERS})

set(QRC_FILES
 resources.qrc
)
qt5_add_resources(QRC_SOURCES ${QRC_FILES})

#set(EXT_PROJECTS_DIR "3rdparty")
#add_subdirectory(${EXT_PROJECTS_DIR}/pcg)
#include_directories(${PCG_INCLUDE_DIR})

add_executable(bridge ${SOURCES} ${MOC_SOURCES} ${QRC_SOURCES})
#target_link_libraries(bridge
#  ${OPENSSL_LIBRARIES}
#)
#add_dependencies(bridge pcg RapidJSON)
qt5_use_modules(bridge Core Gui Qml Quick)

install(TARGETS bridge
  RUNTIME DESTINATION .
)
