#!/bin/bash

PROJ=$(cd `dirname $0`; pwd)

export QUICK_V3_ROOT="../../../../../quick-v3"
export COCOS2DX_ROOT=$QUICK_V3_ROOT

echo "- config:"
echo "  ANDROID_NDK_PATH = $ANDROID_NDK_PATH"
echo "  COCOS2DX_ROOT    = $COCOS2DX_ROOT"
echo "  QUICK_V3_ROOT    = $QUICK_V3_ROOT"

# 编译参数

build_cpp_debug()
{
    echo "================================="
    echo "========[Build Cpp Debug]========"
    echo "================================="

    "$ANDROID_NDK_PATH"/ndk-build NDK_DEBUG=1 NDK_MODULE_PATH=$COCOS2DX_ROOT NDK_OUT=build NDK_LIBS_OUT=jniLibs/debug
}

build_cpp_release()
{
    echo "==================================="
    echo "========[Build Cpp Release]========"
    echo "==================================="

    "$ANDROID_NDK_PATH"/ndk-build NDK_DEBUG=0 NDK_MODULE_PATH=$COCOS2DX_ROOT NDK_OUT=build NDK_LIBS_OUT=jniLibs/release
}

build_cpp_clean()
{
    echo "================================="
    echo "========[Build Cpp Clean]========"
    echo "================================="

    "$ANDROID_NDK_PATH"/ndk-build clean NDK_DEBUG=1 NDK_MODULE_PATH=$COCOS2DX_ROOT NDK_OUT=build
    "$ANDROID_NDK_PATH"/ndk-build clean NDK_DEBUG=0 NDK_MODULE_PATH=$COCOS2DX_ROOT NDK_OUT=build
}

# 编译参数

CMD=$1

if [ -z $CMD ] ; then
    CMD="help"
fi

if [ $CMD == "debug"   ] ; then build_cpp_debug   ; fi
if [ $CMD == "release" ] ; then build_cpp_release ; fi
if [ $CMD == "clean"   ] ; then build_cpp_clean   ; fi
