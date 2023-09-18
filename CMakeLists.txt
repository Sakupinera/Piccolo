# 指定CMake的最低版本要求，如果低于这个版本，就会报错并终止CMake的执行
cmake_minimum_required(VERSION 3.19 FATAL_ERROR)

# 定义项目的名称和版本号，这些信息可以在其他地方使用，比如生成安装包或者显示版权信息
project(Piccolo VERSION 0.1.0)

# 设置C++的标准版本为17，也就是C++17，这是一个全局变量，会影响所有的目标文
set(CMAKE_CXX_STANDARD 17)
# 表示C++的标准版本是必须的，如果编译器不支持C++17，就会报错并终止CMake的执行
set(CMAKE_CXX_STANDARD_REQUIRED ON)
# 表示默认不构建共享库（动态链接库），而是构建静态库，这也是一个全局变量，会影响所有的目标文件
set(BUILD_SHARED_LIBS OFF)

# 包含了一个CMake模块，它提供了一个宏cmake_dependent_option，可以用来定义一些依赖于其他选项的选项
include(CMakeDependentOption)

# ---- Include guards ----
# 判断项目的源代码目录和构建目录是否相同
if(PROJECT_SOURCE_DIR STREQUAL PROJECT_BINARY_DIR)
# 在if语句中输出了一个致命错误的信息，并终止CMake的执行。这是为了防止在源代码目录中构建项目，因为这样会污染源代码目录，并且可能导致无法清理构建文件  
message(
    FATAL_ERROR
      "In-source builds not allowed. Please make a new directory (called a build directory) and run CMake from there."
  )
endif()

# 定义一个变量PICCOLO_ROOT_DIR，它的值是当前源代码目录的路径，也就是项目的根目录
set(PICCOLO_ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
# 设置安装目录的前缀为${PICCOLO_ROOT_DIR}/bin，也就是项目根目录下的bin文件夹。这意味着当执行make install命令时，所有的可执行文件、库文件和其他资源文件都会被复制到这个目录下
set(CMAKE_INSTALL_PREFIX "${PICCOLO_ROOT_DIR}/bin")
#  定义一个变量BINARY_ROOT_DIR，它的值是安装目录的前缀，也就是${PICCOLO_ROOT_DIR}/bin。这个变量可以在其他地方使用，比如设置运行时库的搜索路径或者生成符号链接等
set(BINARY_ROOT_DIR "${CMAKE_INSTALL_PREFIX}/")

# 添加一个子目录engine到当前项目中，这意味着CMake会在engine目录下寻找并执行CMakeLists.txt文件，来构建engine子项目
add_subdirectory(engine)