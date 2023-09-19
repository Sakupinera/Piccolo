# 设置一个变量PRECOMPILE_TOOLS_PATH，它的值是当前源码目录下的bin文件夹的路径
set(PRECOMPILE_TOOLS_PATH "${CMAKE_CURRENT_SOURCE_DIR}/bin")
# 设置一个变量PICCOLO_PRECOMPILE_PARAMS_IN_PATH，它的值是当前源码目录下的source/precompile/precompile.json.in文件的路径
set(PICCOLO_PRECOMPILE_PARAMS_IN_PATH "${CMAKE_CURRENT_SOURCE_DIR}/source/precompile/precompile.json.in")
# 设置一个变量PICCOLO_PRECOMPILE_PARAMS_PATH，它的值是PRECOMPILE_TOOLS_PATH变量加上"/precompile.json"字符串
set(PICCOLO_PRECOMPILE_PARAMS_PATH "${PRECOMPILE_TOOLS_PATH}/precompile.json")
# 将PICCOLO_PRECOMPILE_PARAMS_IN_PATH这个文件复制到PICCOLO_PRECOMPILE_PARAMS_PATH这个路径，并替换其中的一些变量为实际的值
configure_file(${PICCOLO_PRECOMPILE_PARAMS_IN_PATH} ${PICCOLO_PRECOMPILE_PARAMS_PATH})

#
# use wine for linux
# 判断主机系统是否是 Windows
if (CMAKE_HOST_WIN32)
    # 设置一个空变量 PRECOMPILE_PRE_EXE
    set(PRECOMPILE_PRE_EXE)
  # 设置一个变量 PRECOMPILE_PARSER，表示预编译解析器的可执行文件路径，即预编译工具路径下的 PiccoloParser.exe 文件
	set(PRECOMPILE_PARSER ${PRECOMPILE_TOOLS_PATH}/PiccoloParser.exe)
    # 设置一个变量 sys_include，表示系统包含路径，使用通配符 * 表示所有路径
    set(sys_include "*") 
# 否则如果主机系统是 Linux
elseif(${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Linux" )
    # 设置一个空变量 PRECOMPILE_PRE_EXE
    set(PRECOMPILE_PRE_EXE)
  # 设置一个变量 PRECOMPILE_PARSER，表示预编译解析器的可执行文件路径，即预编译工具路径下的 PiccoloParser 文件
	set(PRECOMPILE_PARSER ${PRECOMPILE_TOOLS_PATH}/PiccoloParser)
    # 设置一个变量 sys_include，表示系统包含路径，使用绝对路径 /usr/include/c++/9/ 表示 C++ 9 的标准库头文件所在位置
    set(sys_include "/usr/include/c++/9/") 
    # 执行一个命令，给预编译解析器添加可执行权限，工作目录为预编译工具路径
    #execute_process(COMMAND chmod a+x ${PRECOMPILE_PARSER} WORKING_DIRECTORY ${PRECOMPILE_TOOLS_PATH})
# 否则如果主机系统是苹果 Mac OS X
elseif(CMAKE_HOST_APPLE)
    # 查找 xcrun 程序，并将其路径存储在 XCRUN_EXECUTABLE 变量中
    find_program(XCRUN_EXECUTABLE xcrun)
    # 如果没有找到 xcrun 程序
    if(NOT XCRUN_EXECUTABLE)
      # 输出一条致命错误信息，并终止 CMake 运行
      message(FATAL_ERROR "xcrun not found!!!")
    endif()
    # 执行一个命令，使用 xcrun 程序获取 Mac OS X 的 SDK 平台路径，并将其存储在 osx_sdk_platform_path_test 变量中，同时去掉末尾的空白字符
    execute_process(
      COMMAND ${XCRUN_EXECUTABLE} --sdk macosx --show-sdk-platform-path
      OUTPUT_VARIABLE osx_sdk_platform_path_test
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    # 设置一个空变量 PRECOMPILE_PRE_EXE
    set(PRECOMPILE_PRE_EXE)
  # 设置一个变量 PRECOMPILE_PARSER，表示预编译解析器的可执行文件路径，即预编译工具路径下的 PiccoloParser 文件
	set(PRECOMPILE_PARSER ${PRECOMPILE_TOOLS_PATH}/PiccoloParser)
    # 设置一个变量 sys_include，表示系统包含路径，使用相对路径拼接 SDK 平台路径和 Xcode 工具链中 C++ 标准库头文件所在位置
    set(sys_include "${osx_sdk_platform_path_test}/../../Toolchains/XcodeDefault.xctoolchain/usr/include/c++/v1") 
endif()
# 设置一个变量 PARSER_INPUT，表示解析器的输入文件路径，即构建目录下的 parser_header.h 文件
set (PARSER_INPUT ${CMAKE_BINARY_DIR}/parser_header.h)
### BUILDING ====================================================================================
# 设置一个变量 PRECOMPILE_TARGET，表示预编译的目标名称，即 PiccoloPreCompile
set(PRECOMPILE_TARGET "PiccoloPreCompile")

# Called first time when building target 
# 添加一个自定义目标，使用预编译目标名称作为参数，ALL 表示该目标总是被构建
add_custom_target(${PRECOMPILE_TARGET} ALL

# COMMAND # (DEBUG: DON'T USE )
#     this will make configure_file() is called on each compile
#   ${CMAKE_COMMAND} -E touch ${PRECOMPILE_PARAM_IN_PATH}a

# If more than one COMMAND is specified they will be executed in order...
# 添加一个命令，使用 CMake 命令行工具输出一行分隔符
COMMAND
  ${CMAKE_COMMAND} -E echo "************************************************************* "
# 添加一个命令，使用 CMake 命令行工具输出一行开始信息
COMMAND
  ${CMAKE_COMMAND} -E echo "**** [Precompile] BEGIN "
COMMAND
  ${CMAKE_COMMAND} -E echo "************************************************************* "
# 添加一个命令，调用预编译解析器，并传入预编译参数文件路径、解析器输入文件路径、引擎根目录下的 source 文件夹路径、系统包含路径、字符串 Piccolo 和数字 0 作为参数
COMMAND
    ${PRECOMPILE_PARSER} "${PICCOLO_PRECOMPILE_PARAMS_PATH}"  "${PARSER_INPUT}"  "${ENGINE_ROOT_DIR}/source" ${sys_include} "Piccolo" 0
### BUILDING ====================================================================================
# 添加一个命令，使用 CMake 命令行工具输出一行结束信息
COMMAND
    ${CMAKE_COMMAND} -E echo "+++ Precompile finished +++"
)
