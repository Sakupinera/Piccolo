
# PackageProject.cmake will be used to make our target installable
# 设置变量TARGET_NAME的值为PiccoloRuntime，这个变量在后面的代码中被用作库的名称
set(TARGET_NAME PiccoloRuntime)

# 设置C++标准为C++17，并要求必须使用这个标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 设置JSON_INCLUDE变量，它指向json11库的位置
set(JSON_INCLUDE ${THIRD_PARTY_DIR}/json11)
# 添加一个名为json11的库，源文件是json11.cpp
add_library(json11 ${JSON_INCLUDE}/json11.cpp)
# 设置json11库的属性，将其放在"ThirdParty/json11"文件夹中
set_target_properties(json11 PROPERTIES FOLDER "ThirdParty/json11")
# ---- Add source files ----

# Note: globbing sources is considered bad practice as CMake's generators may not detect new files
# automatically. Keep that in mind when changing files, or explicitly mention them here.
# 使用glob命令查找所有.h和.cpp文件，并将路径存储在HEADER_FILES和SOURCE_FILES变量中
file(GLOB_RECURSE HEADER_FILES "*.h")
file(GLOB_RECURSE SOURCE_FILES "*.cpp")

#source_group(TREE "${ENGINE_ROOT_DIR}/schema" FILES ${SCHEMA_FILES})
# 将当前源目录下的所有头文件和源文件添加到源组中
source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}" FILES ${HEADER_FILES} ${SOURCE_FILES})


# if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/schema/)
#   file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/schema/" DESTINATION "${CMAKE_BINARY_DIR}/schema")
# endif()

# if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/asset/)
#   file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/asset/" DESTINATION "${CMAKE_BINARY_DIR}/asset")
# endif()
# ---- Create library ----

# Note: for header-only libraries change all PUBLIC flags to INTERFACE and create an interface
# target: add_library(${TARGET_NAME} INTERFACE)
# 创建一个名为PiccoloRuntime的库，包含之前找到的所有头文件和源文件
add_library(${TARGET_NAME} ${HEADER_FILES} ${SOURCE_FILES})
# 设置PiccoloRuntime库使用C++17标准
set_target_properties(${TARGET_NAME} PROPERTIES CXX_STANDARD 17)
set_target_properties(${TARGET_NAME} PROPERTIES FOLDER "Engine")

# being a cross-platform target, we enforce standards conformance on MSVC
# 如果编译器是MSVC，则添加编译选项/permissive-和/WX-
target_compile_options(${TARGET_NAME} PUBLIC "$<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/permissive->")
target_compile_options(${TARGET_NAME} PUBLIC "$<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/WX->")

# Link dependencies    
# 链接PiccoloRuntime库所依赖的其他库
target_link_libraries(${TARGET_NAME} PUBLIC spdlog::spdlog)
target_link_libraries(${TARGET_NAME} PRIVATE tinyobjloader stb)
target_link_libraries(${TARGET_NAME} PUBLIC glfw)
target_link_libraries(${TARGET_NAME} PUBLIC imgui)
target_link_libraries(${TARGET_NAME} PUBLIC Jolt)
target_link_libraries(${TARGET_NAME} PUBLIC lua_static sol2)
target_link_libraries(${TARGET_NAME} PUBLIC ${vulkan_lib})
target_link_libraries(${TARGET_NAME} PRIVATE $<BUILD_INTERFACE:json11>)

# 如果启用了物理调试渲染器，则添加编译定义ENABLE_PHYSICS_DEBUG_RENDERER，并链接TestFramework、d3d12.lib和shcore.lib库
if(ENABLE_PHYSICS_DEBUG_RENDERER)
  add_compile_definitions(ENABLE_PHYSICS_DEBUG_RENDERER)
  target_link_libraries(${TARGET_NAME} PUBLIC TestFramework d3d12.lib shcore.lib)
endif()

# 添加PiccoloRuntime库的头文件搜索路径
# target_include_directories用于指定一个目标需要的头文件的位置。它有三个参数：目标名，作用域和路径列表
target_include_directories(
  ${TARGET_NAME}
  PUBLIC $<BUILD_INTERFACE:${vulkan_include}>)

# add_dependencies用于指定一个目标依赖于另一个目标。它有两个参数：目标名和依赖目标名
add_dependencies(${TARGET_NAME} ${SHADER_COMPILE_TARGET})
target_include_directories(
  ${TARGET_NAME}
  PUBLIC $<BUILD_INTERFACE:${ENGINE_ROOT_DIR}/shader/generated/cpp>)


target_include_directories(
  ${TARGET_NAME} 
  PUBLIC $<BUILD_INTERFACE:${ENGINE_ROOT_DIR}/source>
  $<INSTALL_INTERFACE:include/${TARGET_NAME}-${PROJECT_VERSION}>
)



target_include_directories(
  ${TARGET_NAME} 
  PUBLIC $<BUILD_INTERFACE:${JSON_INCLUDE}>
)

target_include_directories(
  ${TARGET_NAME} 
  PUBLIC $<BUILD_INTERFACE:${THIRD_PARTY_DIR}/vulkanmemoryallocator/include>
)

target_include_directories(
  ${TARGET_NAME} 
  PUBLIC $<BUILD_INTERFACE:${ENGINE_ROOT_DIR}/source/runtime>
  $<INSTALL_INTERFACE:include/${TARGET_NAME}-${PROJECT_VERSION}>
)

target_include_directories(
  ${TARGET_NAME} 
  PUBLIC $<BUILD_INTERFACE:${ENGINE_ROOT_DIR}/source/runtime/function/render/include>
  $<INSTALL_INTERFACE:include/${TARGET_NAME}-${PROJECT_VERSION}>
)

# ---- Create an installable target ----
# this allows users to install and find the library via `find_package()`.

# the location where the project's version header will be placed should match the project's regular
# header paths
# 将TARGET_NAME转换为小写，并拼接/version.h，结果存储在VERSION_HEADER_LOCATION变量中
string(TOLOWER ${TARGET_NAME}/version.h VERSION_HEADER_LOCATION)


### precompile
# set global vari used by precompile
# 将HEADER_FILES变量的值传递给父级作用域，变量名为PICCOLO_RUNTIME_HEADS。这样父级作用域就可以访问到这个变量了
set(PICCOLO_RUNTIME_HEADS "${HEADER_FILES}" PARENT_SCOPE)
