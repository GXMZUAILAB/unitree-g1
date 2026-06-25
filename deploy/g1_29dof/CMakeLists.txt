cmake_minimum_required(VERSION 3.12)
project(g1_29dof_controller)

set(CMAKE_CXX_STANDARD 17)

find_package(Boost REQUIRED COMPONENTS program_options)
find_package(yaml-cpp REQUIRED)

# ONNX Runtime path — use env var if set, otherwise auto-detect arch
if(DEFINED ENV{ONNXRUNTIME_ROOT})
    set(ONNXRUNTIME_ROOT "$ENV{ONNXRUNTIME_ROOT}")
else()
    # Compute absolute path from g1_29dof/ to thirdparty/
    get_filename_component(DEPLOY_ROOT "${PROJECT_SOURCE_DIR}/.." ABSOLUTE)
    if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64")
        set(ONNXRUNTIME_ROOT "${DEPLOY_ROOT}/thirdparty/onnxruntime-linux-aarch64-1.22.0")
    else()
        set(ONNXRUNTIME_ROOT "${DEPLOY_ROOT}/thirdparty/onnxruntime-linux-x64-1.22.0")
    endif()
endif()
message(STATUS "ONNXRUNTIME_ROOT = ${ONNXRUNTIME_ROOT}")

include_directories(
  /usr/include/eigen3
  /usr/local/include/ddscxx # dds
  /usr/local/include/iceoryx/v2.0.2 # dds
  include
  ${ONNXRUNTIME_ROOT}/include
  ${PROJECT_SOURCE_DIR}/../include/
)

# Use bundled SDK lib (matching our headers) if available;
# otherwise fall back to system-installed libunitree_sdk2.
if(EXISTS "${PROJECT_SOURCE_DIR}/lib/libunitree_sdk2.a")
    set(UNITREE_SDK2_LIB "${PROJECT_SOURCE_DIR}/lib/libunitree_sdk2.a")
else()
    set(UNITREE_SDK2_LIB unitree_sdk2)
endif()

link_libraries(
  ${UNITREE_SDK2_LIB} ddsc ddscxx rt pthread # dds
  boost_program_options yaml-cpp fmt
  ${ONNXRUNTIME_ROOT}/lib/libonnxruntime.so.1.22.0
)

file(GLOB_RECURSE ADD_SRC_LIST
  ${PROJECT_SOURCE_DIR}/src/*.cpp
)

add_library(${PROJECT_NAME}_lib ${ADD_SRC_LIST})
link_libraries(${PROJECT_NAME}_lib)

add_executable(g1_ctrl main.cpp)
