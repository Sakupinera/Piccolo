# 设置目标名称为PiccoloEditor
set(TARGET_NAME PiccoloEditor)

# 使用通配符搜索当前目录下的头文件、源文件和资源文件，并将它们分配给相应的变量
file(GLOB EDITOR_HEADERS CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/include/*.h)
file(GLOB EDITOR_SOURCES CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/source/*.cpp)
file(GLOB EDITOR_RESOURCE CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/resource/PiccoloEditor.rc)

# 根据当前目录的结构对文件进行分组，方便在IDE中查看
source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}" FILES ${EDITOR_HEADERS} ${EDITOR_SOURCES} ${EDITOR_RESOURCE})

# 添加一个可执行目标，使用之前搜索到的文件
add_executable(${TARGET_NAME} ${EDITOR_HEADERS} ${EDITOR_SOURCES} ${EDITOR_RESOURCE})

# 添加一个编译定义，指定Piccolo根目录的路径
add_compile_definitions("PICCOLO_ROOT_DIR=${BINARY_ROOT_DIR}")

# 添加一个包含目录，用于引用第三方库stb的头文件
target_include_directories(
  ${TARGET_NAME} 
  PUBLIC $<BUILD_INTERFACE:${THIRD_PARTY_DIR}/stb>
)

# 设置目标的属性，包括C++标准、输出名称和文件夹
set_target_properties(${TARGET_NAME} PROPERTIES CXX_STANDARD 17 OUTPUT_NAME "PiccoloEditor")
set_target_properties(${TARGET_NAME} PROPERTIES FOLDER "Engine")

# 设置目标的编译选项，使用MSVC编译器时禁用警告
target_compile_options(${TARGET_NAME} PUBLIC "$<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/WX->")

# 设置目标的链接库，链接PiccoloRuntime库
target_link_libraries(${TARGET_NAME} PiccoloRuntime)

# 设置一系列后续命令，用于在构建完成后执行，包括创建目录、复制文件和删除文件
set(POST_BUILD_COMMANDS
  COMMAND ${CMAKE_COMMAND} -E make_directory "${BINARY_ROOT_DIR}"
  COMMAND ${CMAKE_COMMAND} -E copy_directory "${CMAKE_CURRENT_SOURCE_DIR}/resource" "${BINARY_ROOT_DIR}/resource"
  COMMAND ${CMAKE_COMMAND} -E copy_directory "$<TARGET_FILE_DIR:${TARGET_NAME}>/" "${BINARY_ROOT_DIR}"
  COMMAND ${CMAKE_COMMAND} -E copy "${ENGINE_ROOT_DIR}/${DEPLOY_CONFIG_DIR}/${TARGET_NAME}.ini" "${BINARY_ROOT_DIR}"
  COMMAND ${CMAKE_COMMAND} -E copy "${ENGINE_ROOT_DIR}/${DEVELOP_CONFIG_DIR}/${TARGET_NAME}.ini" "$<TARGET_FILE_DIR:${TARGET_NAME}>/"
  COMMAND ${CMAKE_COMMAND} -E remove_directory "${BINARY_ROOT_DIR}/${ENGINE_ASSET_DIR}"
  COMMAND ${CMAKE_COMMAND} -E copy_directory "${ENGINE_ROOT_DIR}/${ENGINE_ASSET_DIR}" "${BINARY_ROOT_DIR}/${ENGINE_ASSET_DIR}"
)


# 如果启用了物理调试渲染器，那么还需要复制Jolt的资源文件
if(ENABLE_PHYSICS_DEBUG_RENDERER)
  set(POST_BUILD_COMMANDS ${POST_BUILD_COMMANDS}
    COMMAND ${CMAKE_COMMAND} -E remove_directory "${BINARY_ROOT_DIR}/${JOLT_ASSET_DIR}"
    COMMAND ${CMAKE_COMMAND} -E copy_directory "${ENGINE_ROOT_DIR}/${JOLT_ASSET_DIR}" "${BINARY_ROOT_DIR}/${JOLT_ASSET_DIR}"
)
endif()

# 添加一个自定义命令，使用之前设置的后续命令
add_custom_command(TARGET ${TARGET_NAME} ${POST_BUILD_COMMANDS})

#precompile
#set global vari used by precompile
set(PICCOLO_EDITOR_HEADS “${EDITOR_HEADERS}” PARENT_SCOPE)
