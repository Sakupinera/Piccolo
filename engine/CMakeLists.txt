# 定义一个变量ENGINE_ROOT_DIR，它的值是${PICCOLO_ROOT_DIR}/engine，也就是项目根目录下的engine文件夹的路径
set(ENGINE_ROOT_DIR "${PICCOLO_ROOT_DIR}/engine")
# 定义一个变量THIRD_PARTY_DIR，它的值是${ENGINE_ROOT_DIR}/3rdparty，也就是engine文件夹下的3rdparty文件夹的路径，这个文件夹存放了一些第三方库的源码或者预编译的二进制文件
set(THIRD_PARTY_DIR "${ENGINE_ROOT_DIR}/3rdparty")
# 定义一个变量ENGINE_ASSET_DIR，它的值是/asset，这个值表示引擎的资源文件夹的相对路径，也就是相对于安装目录的路径。这个文件夹存放了一些引擎需要的图片、音频、字体等资源文件
set(ENGINE_ASSET_DIR "/asset")

# 定义一个变量DEPLOY_CONFIG_DIR，它的值是configs/deployment，这个值表示部署配置文件夹的相对路径，也就是相对于安装目录的路径。这个文件夹存放了一些用于部署时使用的配置文件，比如日志级别、窗口大小、渲染选项等
set(DEPLOY_CONFIG_DIR "configs/deployment")
# 定义一个变量DEVELOP_CONFIG_DIR，它的值是configs/development，这个值表示开发配置文件夹的相对路径，也就是相对于安装目录的路径。这个文件夹存放了一些用于开发时使用的配置文件，比如调试选项、热重载选项、测试场景等
set(DEVELOP_CONFIG_DIR "configs/development")

# 定义了一个选项ENABLE_PHYSICS_DEBUG_RENDERER，它给用户提供了一个开关来决定是否启用物理调试渲染器。
# 物理调试渲染器可以在运行时显示物理对象的形状、速度、碰撞等信息。这个选项的提示信息是"Enable Physics Debug Renderer"，默认值是OFF，也就是关闭状态
option(ENABLE_PHYSICS_DEBUG_RENDERER "Enable Physics Debug Renderer" OFF)

# only support physics debug render at windows platform
if(NOT WIN32)
  if(ENABLE_PHYSICS_DEBUG_RENDERER)
    # 输出一个警告信息，并不终止CMake的执行。这个信息告诉用户关闭物理调试渲染器，因为当前平台不支持它
    message(WARNING "Disable Physics Debug Renderer")
    # 强制设置了物理调试渲染器为关闭状态，并把它保存到缓存中。这样做的目的是防止用户在非Windows平台上使用物理调试渲染器
    set(ENABLE_PHYSICS_DEBUG_RENDERER OFF CACHE BOOL "" FORCE)
  endif()
endif()

# 如果ENABLE_PHYSICS_DEBUG_RENDERER选项为真，设置一个变量JOLT_ASSET_DIR，它的值是"/jolt-asset"字符串
if(ENABLE_PHYSICS_DEBUG_RENDERER)
  set(JOLT_ASSET_DIR "/jolt-asset")
endif()

# 如果当前使用的C++编译器是微软的Visual C++
if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    # 添加一个编译选项"/MP"，它表示启用多核编译
    add_compile_options("/MP")
    # 设置当前源码目录的一个属性VS_STARTUP_PROJECT，它的值是PiccoloEditor，表示在Visual Studio中默认启动这个项目
    set_property(DIRECTORY ${CMAKE_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT PiccoloEditor)
endif()

# 设置一个变量vulkan_include，它的值是THIRD_PARTY_DIR变量加上"/VulkanSDK/include"字符串
set(vulkan_include ${THIRD_PARTY_DIR}/VulkanSDK/include)

# 如果当前平台是Windows 32位系统或64位系统
if(WIN32)
    # 设置一个变量vulkan_lib，它的值是THIRD_PARTY_DIR变量加上"/VulkanSDK/lib/Win32/vulkan-1.lib"字符串
    set(vulkan_lib ${THIRD_PARTY_DIR}/VulkanSDK/lib/Win32/vulkan-1.lib)
    # 设置一个变量glslangValidator_executable，它的值是THIRD_PARTY_DIR变量加上"/VulkanSDK/bin/Win32/glslangValidator.exe"字符串
    set(glslangValidator_executable ${THIRD_PARTY_DIR}/VulkanSDK/bin/Win32/glslangValidator.exe)
    # 添加一个编译时定义PICCOLO_VK_LAYER_PATH，它的值是THIRD_PARTY_DIR变量加上"/VulkanSDK/bin/Win32"字符串
    add_compile_definitions("PICCOLO_VK_LAYER_PATH=${THIRD_PARTY_DIR}/VulkanSDK/bin/Win32")
# 否则如果当前平台是Unix或类Unix系统（如Linux或MacOS）
elseif(UNIX)
    # 如果当前平台是MacOS系统
    if(APPLE)
      # 设置一个变量vulkan_lib，它的值是THIRD_PARTY_DIR变量加上"/VulkanSDK/lib/MacOS/libvulkan.1.dylib"字符串
      set(vulkan_lib ${THIRD_PARTY_DIR}/VulkanSDK/lib/MacOS/libvulkan.1.dylib)
      # 设置一个变量glslangValidator_executable，它的值是THIRD_PARTY_DIR变量加上"/VulkanSDK/bin/MacOS/glslangValidator"字符串
      set(glslangValidator_executable ${THIRD_PARTY_DIR}/VulkanSDK/bin/MacOS/glslangValidator)
      # 添加一个编译时定义PICCOLO_VK_LAYER_PATH，它的值是THIRD_PARTY_DIR变量加上"/VulkanSDK/bin/MacOS"字符串
      add_compile_definitions("PICCOLO_VK_LAYER_PATH=${THIRD_PARTY_DIR}/VulkanSDK/bin/MacOS")
      # 添加一个编译时定义PICCOLO_VK_ICD_FILENAMES，它的值是THIRD_PARTY_DIR变量加上"/VulkanSDK/bin/MacOS/MoltenVK_icd.json"字符串
      add_compile_definitions("PICCOLO_VK_ICD_FILENAMES=${THIRD_PARTY_DIR}/VulkanSDK/bin/MacOS/MoltenVK_icd.json")
    else()
      # 设置一个变量vulkan_lib，它的值是THIRD_PARTY_DIR变量加上"/VulkanSDK/lib/Linux/libvulkan.so.1"字符串
      set(vulkan_lib ${THIRD_PARTY_DIR}/VulkanSDK/lib/Linux/libvulkan.so.1)
      # 设置一个变量glslangValidator_executable，它的值是THIRD_PARTY_DIR变量加上"/VulkanSDK/bin/Linux/glslangValidator"字符串
      set(glslangValidator_executable ${THIRD_PARTY_DIR}/VulkanSDK/bin/Linux/glslangValidator)
      # 添加一个编译时定义PICCOLO_VK_LAYER_PATH，它的值是THIRD_PARTY_DIR变量加上"/VulkanSDK/bin/Linux"字符串
      add_compile_definitions("PICCOLO_VK_LAYER_PATH=${THIRD_PARTY_DIR}/VulkanSDK/bin/Linux")
    endif()
else()
  # 输出一条致命错误信息"Unknown Platform"，并终止CMake运行
  message(FATAL_ERROR "Unknown Platform")
endif()

# 设置一个变量SHADER_COMPILE_TARGET，它的值是PiccoloShaderCompile字符串
set(SHADER_COMPILE_TARGET PiccoloShaderCompile)
# 添加一个子目录shader，它包含了CMakeLists.txt文件，用于构建shader相关的目标
add_subdirectory(shader)

# 添加一个子目录3rdparty，它包含了CMakeLists.txt文件，用于构建第三方库相关的目标
add_subdirectory(3rdparty)

# 添加一个子目录source/runtime，它包含了CMakeLists.txt文件，用于构建运行时相关的目标
add_subdirectory(source/runtime)
# 添加一个子目录source/editor，它包含了CMakeLists.txt文件，用于构建编辑器相关的目标
add_subdirectory(source/editor)
# 添加一个子目录source/meta_parser，它包含了CMakeLists.txt文件，用于构建元数据解析器相关的目标
add_subdirectory(source/meta_parser)
#add_subdirectory(source/test)

# 设置一个变量CODEGEN_TARGET，它的值是PiccoloPreCompile字符串
set(CODEGEN_TARGET "PiccoloPreCompile")
# 包含一个文件source/precompile/precompile.cmake，它定义了一些预编译相关的函数和变量
include(source/precompile/precompile.cmake)
# 设置CODEGEN_TARGET这个目标的一些属性，其中FOLDER属性表示在Visual Studio中将这个目标归类到Engine文件夹下
set_target_properties("${CODEGEN_TARGET}" PROPERTIES FOLDER "Engine" )

# 表示PiccoloRuntime这个目标依赖于CODEGEN_TARGET这个目标，在构建前要先构建CODEGEN_TARGET
add_dependencies(PiccoloRuntime "${CODEGEN_TARGET}")
# 表示CODEGEN_TARGET这个目标依赖于PiccoloParser这个目标，在构建前要先构建PiccoloParser
add_dependencies("${CODEGEN_TARGET}" "PiccoloParser")
