# 设置CMake策略CMP0074为旧版本，该策略控制了CMake如何查找包含目录和库目录
#cmake_policy(SET CMP0074 OLD)
# 设置生成的可执行文件的名称
set(TARGET_NAME PiccoloParser)

# 设置CMAKE_MODULE_PATH变量，其值为当前列表文件所在目录的上级目录下的CMake文件夹，该变量用于指定CMake模块的搜索路径
#set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../CMake")

# 设置全局属性USE_FOLDERS为ON，表示启用IDE中的文件夹功能
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# 使用file命令的GLOB_RECURSE选项，将所有.h文件放入HEADERS变量中
file(GLOB_RECURSE HEADERS "*.h")
# 使用file命令的GLOB_RECURSE选项，将所有.cpp文件放入SOURCES变量中
file(GLOB_RECURSE SOURCES "*.cpp")

# 根据当前源代码目录下的文件结构创建IDE中的源代码分组
source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}" FILES ${HEADERS} ${SOURCES})

# 设置一个变量LLVM_INCLUDE_DIRS，它的值是三个目录的路径，分别是当前源码目录下的3rd_party/LLVM/include，3rd_party/mustache和当前源码目录本身。这些目录包含了一些头文件，后面会用到
set(LLVM_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/LLVM/include ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/mustache ${CMAKE_CURRENT_SOURCE_DIR})
# 设置一个变量CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE，它的值是${ENGINE_ROOT_DIR}/bin，也就是引擎根目录下的bin子目录。这个变量表示在Release模式下编译时，可执行文件的输出目录
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ${ENGINE_ROOT_DIR}/bin)
# 设置一个变量CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG，它的值也是${ENGINE_ROOT_DIR}/bin。这个变量表示在Debug模式下编译时，可执行文件的输出目录
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ${ENGINE_ROOT_DIR}/bin)
# add LLVM includes
# 告诉编译器要在哪些目录下寻找头文件。它使用了前面定义的变量LLVM_INCLUDE_DIRS，以及当前源码目录下的parser子目录
include_directories(${LLVM_INCLUDE_DIRS} ${CMAKE_CURRENT_SOURCE_DIR}/parser)

# header files are superflous, but some IDEs (Visual Studio) don't include
# them in the solution explorer without them being added to the list of sources
# 生成一个名为${TARGET_NAME}的可执行文件，它使用了两个变量${HEADERS}和${SOURCES}，分别表示头文件列表和源文件列表
add_executable(${TARGET_NAME} ${HEADERS} ${SOURCES})

#set_target_properties(meta_parser PROPERTIES FOLDER "generator" ) 
# 给当前的目标（也就是${TARGET_NAME}）设置一个属性CXX_STANDARD 17，表示它要使用C++17标准进行编译
set_target_properties(${TARGET_NAME} PROPERTIES CXX_STANDARD 17)
# 给当前的目标设置一个属性FOLDER "Tools"，表示它属于一个名为Tools的文件夹
set_target_properties(${TARGET_NAME} PROPERTIES FOLDER "Tools")

# 判断当前主机是否是Windows系统
if (CMAKE_HOST_WIN32)
    # 设置一个变量LLVM_LIBRARY_DIR，它的值是当前源码目录下的3rd_party/LLVM/lib/x64子目录。这个目录包含了一些静态库文件，后面会用到
    set(LLVM_LIBRARY_DIR  ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/LLVM/lib/x64)
    # 设置一个变量 LLVM_SHARED_LIBRARY_DIR，它的值是当前源码目录下的3rd_party/LLVM/bin/x64子目录。这个目录包含了一些动态库文件，后面会用到
    set(LLVM_SHARED_LIBRARY_DIR  ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/LLVM/bin/x64)
    # 设置一个变量CMAKE_CXX_FLAGS_DEBUG，它的值是环境变量CXXFLAGS的值加上两个编译选项/O2 /Ob2。这个变量表示在Debug模式下编译时，要传递给编译器的额外参数
    set(CMAKE_CXX_FLAGS_DEBUG "$ENV{CXXFLAGS} /O2 /Ob2")
    # 告诉CMake要给当前的目标（也就是${TARGET_NAME}）链接一个名为${LLVM_LIBRARY_DIR}/libclang.lib的静态库文件。
    # 这个文件是前面定义的变量LLVM_LIBRARY_DIR下的一个文件，它是LLVM项目中的一个库，提供了对C语言族的分析和转换功能
    target_link_libraries(${TARGET_NAME}  ${LLVM_LIBRARY_DIR}/libclang.lib)
# 当前主机是否是Linux系统
elseif(${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Linux")
    # 设置一个变量 LLVM_LIBRARY_DIR，它的值是当前源码目录下的3rd_party/LLVM/lib/Linux子目录
    set(LLVM_LIBRARY_DIR  ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/LLVM/lib/Linux)
    # 设置一个变量 LLVM_SHARED_LIBRARY_DIR，它的值是当前源码目录下的3rd_party/LLVM/bin/Linux子目录。这个目录包含了一些动态库文件，后面会用到
    set(LLVM_SHARED_LIBRARY_DIR  ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/LLVM/bin/Linux)
    # 设置一个变量 CMAKE_CXX_FLAGS_DEBUG，它的值是环境变量 CXXFLAGS的值加上一个编译选项 -O3。这个变量表示在Debug模式下编译时，要传递给编译器的额外参数
    set(CMAKE_CXX_FLAGS_DEBUG "$ENV{CXXFLAGS} -O3")
    # 告诉CMake要给当前的目标（也就是${TARGET_NAME}）链接一个名为${LLVM_SHARED_LIBRARY_DIR}/libclang.so.12的动态库文件
    target_link_libraries(${TARGET_NAME}  ${LLVM_SHARED_LIBRARY_DIR}/libclang.so.12)
# 判断当前主机是否是arm64架构
elseif(${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL "arm64") 
    # link to XCode Toolchains' universal binary libclang.dylib 
    # 设置一个变量 LLVM_LIBRARY_DIR ，它的值是当前源码目录下的 3rd_party/LLVM/lib/macOS 子目录。这个目录包含了一些静态库文件，后面会用到
    set(LLVM_LIBRARY_DIR  ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/LLVM/lib/macOS)
    # 设置一个变量 LLVM_SHARED_LIBRARY_DIR ，它的值是 ${OSX_DEVELOPER_ROOT}/Toolchains/XcodeDefault.xctoolchain/usr/lib ，也就是XCode工具链的根目录下的 usr/lib 子目录。这个目录包含了一些动态库文件，后面会用到
    set(LLVM_SHARED_LIBRARY_DIR  ${OSX_DEVELOPER_ROOT}/Toolchains/XcodeDefault.xctoolchain/usr/lib)
    # 设置一个变量 CMAKE_CXX_FLAGS_DEBUG ，它的值是环境变量 CXXFLAGS 的值加上一个编译选项 -O3。这个变量表示在Debug模式下编译时，要传递给编译器的额外参数
    set(CMAKE_CXX_FLAGS_DEBUG "$ENV{CXXFLAGS} -O3")
    # 告诉CMake要给当前的目标（也就是${TARGET_NAME}）链接一个名为${LLVM_SHARED_LIBRARY_DIR}/libclang.dylib的动态库文件
    target_link_libraries(${TARGET_NAME}  ${LLVM_SHARED_LIBRARY_DIR}/libclang.dylib)    
else()
    # 设置一个变量 LLVM_LIBRARY_DIR ，它的值是当前源码目录下的 3rd_party/LLVM/lib/macOS 子目录。这个目录包含了一些静态库文件，后面会用到
    set(LLVM_LIBRARY_DIR  ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/LLVM/lib/macOS)
    # 设置一个变量 LLVM_SHARED_LIBRARY_DIR ，它的值是当前源码目录下的 3rd_party/LLVM/bin/macOS 子目录。这个目录包含了一些动态库文件，后面会用到
    set(LLVM_SHARED_LIBRARY_DIR  ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/LLVM/bin/macOS)
    # 设置一个变量 CMAKE_CXX_FLAGS_DEBUG ，它的值是环境变量 CXXFLAGS 的值加上一个编译选项 -O3。这个变量表示在Debug模式下编译时，要传递给编译器的额外参数
    set(CMAKE_CXX_FLAGS_DEBUG "$ENV{CXXFLAGS} -O3")
    # 告诉CMake要给当前的目标（也就是${TARGET_NAME}）链接一个名为${LLVM_SHARED_LIBRARY_DIR}/libclang.dylib的动态库文件
    target_link_libraries(${TARGET_NAME}  ${LLVM_SHARED_LIBRARY_DIR}/libclang.dylib)
endif()

#link_directories(${LLVM_LIBRARY_DIR})

# statically link with Boost & LibClang

# 告诉CMake要给当前的目标（也就是${TARGET_NAME}）添加一个编译定义-DTIXML_USE_STL，表示要使用STL（标准模板库）来处理XML文件。这个定义是为了使用一个名为TinyXML的第三方库，它可以解析和生成XML文件
add_definitions(-DTIXML_USE_STL)

# copy resources on post build
# 开始了一个自定义命令，它的参数是TARGET ${TARGET_NAME} POST_BUILD，表示这个命令要在当前的目标（也就是${TARGET_NAME}）编译完成后执行
add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
	# mustache templates directory
    # 指定了一个命令，它的参数是${CMAKE_COMMAND} -E copy_directory "${LLVM_SHARED_LIBRARY_DIR}" $<TARGET_FILE_DIR:${TARGET_NAME}>，表示要使用CMake自带的命令来复制一个目录。
    # 这个命令要复制前面定义的变量${LLVM_SHARED_LIBRARY_DIR}下的所有文件和子目录到另一个目录，这个目录是当前目标的输出目录，也就是可执行文件所在的目录。
    # 这样做的目的是为了把一些动态库文件复制到可执行文件所在的目录，以便运行时能够找到它们。
	COMMAND ${CMAKE_COMMAND} -E copy_directory
		"${LLVM_SHARED_LIBRARY_DIR}"
		$<TARGET_FILE_DIR:${TARGET_NAME}>
)

