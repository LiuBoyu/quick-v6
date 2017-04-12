#!/bin/bash

export PATH="$PATH:/usr/local/bin"

# 编译参数

APP_ROOT="$PWD/../../.."
APP_IOS_ROOT="$PWD"
APP_ASSETS_ROOT="$TARGET_BUILD_DIR/$CONTENTS_FOLDER_PATH"

echo "- config:"
echo "  CONFIGURATION   = $CONFIGURATION"
echo "  APP_ROOT        = $APP_ROOT"
echo "  APP_IOS_ROOT    = $APP_IOS_ROOT"
echo "  APP_ASSETS_ROOT = $APP_ASSETS_ROOT"

# 编译函数

build_lua_debug()
{
    echo "================================="
    echo "========[Build Lua Debug]========"
    echo "================================="

    cp -RL $APP_ROOT/src        $APP_ASSETS_ROOT/src
    cp -RL $APP_ROOT/src.ext    $APP_ASSETS_ROOT/src.ext
    cp -RL $APP_ROOT/res        $APP_ASSETS_ROOT/res
    cp -RL $APP_ROOT/res.ext    $APP_ASSETS_ROOT/res.ext
}

build_lua_release()
{
    echo "==================================="
    echo "========[Build Lua Release]========"
    echo "==================================="
}

build_lua_clean()
{
    echo "================================="
    echo "========[Build Lua Clean]========"
    echo "================================="

    rm -rf $APP_ASSETS_ROOT/src
    rm -rf $APP_ASSETS_ROOT/src.ext
    rm -rf $APP_ASSETS_ROOT/res
    rm -rf $APP_ASSETS_ROOT/res.ext
}

# 编译执行

if [ $CONFIGURATION = "Debug" ] ; then

    build_lua_clean
    build_lua_debug

else

    build_lua_clean
    build_lua_release

fi

