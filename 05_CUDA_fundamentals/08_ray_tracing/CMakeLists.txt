cmake_minimum_required(VERSION 3.18)

project(rayTracing LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)

set(CMAKE_CUDA_ARCHITECTURES 75)

find_package(VTK REQUIRED)

add_executable(rtx main.cu)

target_link_libraries(rtx PRIVATE ${VTK_LIBRARIES})







