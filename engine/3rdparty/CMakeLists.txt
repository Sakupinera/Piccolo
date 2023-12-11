# 设置第三方库的文件夹名称
set(third_party_folder "ThirdParty")

# 强制关闭构建共享库的选项
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)

# 如果imgui目标不存在，就引入imgui.cmake文件，并设置imgui目标的文件夹属性
if(NOT TARGET imgui)
    include(imgui.cmake)
    set_target_properties(imgui PROPERTIES FOLDER ${third_party_folder}/imgui)
endif()

# 如果glfw目标不存在，就关闭glfw的一些不需要的选项，并添加glfw子目录，并设置glfw相关目标的文件夹属性
if(NOT TARGET glfw)
    option(GLFW_BUILD_EXAMPLES "" OFF)
    option(GLFW_BUILD_TESTS "" OFF)
    option(GLFW_BUILD_DOCS "" OFF)
    option(GLFW_INSTALL "" OFF)
    add_subdirectory(glfw)
    set_target_properties(glfw PROPERTIES FOLDER ${third_party_folder}/glfw)
    set_target_properties(update_mappings PROPERTIES FOLDER ${third_party_folder}/glfw)
endif()

# 如果spdlog目标不存在，就关闭spdlog的一些不需要的选项，并添加spdlog子目录，并设置spdlog目标的文件夹属性
if(NOT TARGET spdlog)
    option(SPDLOG_BUILD_EXAMPLE "" OFF)
    option(SPDLOG_INSTALL "" OFF)
    add_subdirectory(spdlog)
    set_target_properties(spdlog PROPERTIES FOLDER ${third_party_folder}/spdlog)
endif()

# 如果stb目标不存在，就引入stb.cmake文件，并设置stb目标的文件夹属性
if(NOT TARGET stb)
    include(stb.cmake)
    set_target_properties(stb PROPERTIES FOLDER ${third_party_folder}/stb)
endif()

# 如果tinyobjloader目标不存在，就添加tinyobjloader子目录，并设置tinyobjloader相关目标的文件夹属性
if(NOT TARGET tinyobjloader)
    add_subdirectory(tinyobjloader)
    set_target_properties(tinyobjloader PROPERTIES FOLDER ${third_party_folder}/tinyobjloader)
    set_target_properties(uninstall PROPERTIES FOLDER ${third_party_folder}/tinyobjloader)
endif()

# 如果Jolt目标不存在，就关闭Jolt的一些不需要的选项，并添加JoltPhysics/Build子目录
# 如果启用了物理调试渲染器，就打开TARGET_TEST_FRAMEWORK选项，否则关闭
# 如果编译器是Clang，就检查是否支持-Wno-unqualified-std-cast-call选项，如果支持就添加到Jolt目标的编译选项中
# 如果启用了物理调试渲染器，就设置Jolt和TestFramework目标的文件夹属性和运行时库属性，否则只设置Jolt目标的属性
if(NOT TARGET Jolt)
    option(TARGET_HELLO_WORLD "" OFF)
    option(TARGET_PERFORMANCE_TEST "" OFF)
    option(TARGET_SAMPLES "" OFF)
    option(TARGET_UNIT_TESTS "" OFF)
    option(TARGET_VIEWER "" OFF)

    if(ENABLE_PHYSICS_DEBUG_RENDERER)
        option(TARGET_TEST_FRAMEWORK "" ON)
    else()
        option(TARGET_TEST_FRAMEWORK "" OFF)
    endif()

    add_subdirectory(JoltPhysics/Build)

    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        include(CheckCXXCompilerFlag)
        check_cxx_compiler_flag("-Wno-unqualified-std-cast-call" COMPILER_CHECK_UNQUALIFIED)
        if(COMPILER_CHECK_UNQUALIFIED)
            target_compile_options(Jolt PRIVATE "-Wno-unqualified-std-cast-call")
        endif()
    endif()

    if(ENABLE_PHYSICS_DEBUG_RENDERER)
        set_target_properties(Jolt TestFramework
            PROPERTIES 
            FOLDER ${third_party_folder}/JoltPhysics
            MSVC_RUNTIME_LIBRARY "MultiThreadedDLL")
    else()
        set_target_properties(Jolt
            PROPERTIES 
            FOLDER ${third_party_folder}/JoltPhysics
            MSVC_RUNTIME_LIBRARY "MultiThreadedDLL")
    endif()

endif()

# 如果sol2目标不存在，就添加sol2-3.3.0子目录
if(NOT TARGET sol2)
    add_subdirectory(sol2-3.3.0)
endif()

# 如果lua目标不存在，就引入lua.cmake文件
if(NOT TARGET lua)
    include(lua.cmake)
endif()
