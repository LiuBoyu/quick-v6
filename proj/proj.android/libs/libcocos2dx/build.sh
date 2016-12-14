#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "- config:"
echo "  ANDROID_NDK_ROOT = $ANDROID_NDK_ROOT"
echo "  COCOS2DX_ROOT    = $COCOS2DX_ROOT"

# 编译参数

build_cpp_debug()
{
    echo "================================="
    echo "========[Build Cpp Debug]========"
    echo "================================="

    "$ANDROID_NDK_ROOT"/ndk-build NDK_DEBUG=1 NDK_MODULE_PATH=$COCOS2DX_ROOT NDK_OUT=build NDK_LIBS_OUT=jniLibs/debug
}

build_cpp_release()
{
    echo "==================================="
    echo "========[Build Cpp Release]========"
    echo "==================================="

    "$ANDROID_NDK_ROOT"/ndk-build NDK_DEBUG=0 NDK_MODULE_PATH=$COCOS2DX_ROOT NDK_OUT=build NDK_LIBS_OUT=jniLibs/release
}

build_cpp_clean()
{
    echo "================================="
    echo "========[Build Cpp Clean]========"
    echo "================================="

    "$ANDROID_NDK_ROOT"/ndk-build clean NDK_DEBUG=1 NDK_MODULE_PATH=$COCOS2DX_ROOT NDK_OUT=build
    "$ANDROID_NDK_ROOT"/ndk-build clean NDK_DEBUG=0 NDK_MODULE_PATH=$COCOS2DX_ROOT NDK_OUT=build
}

# 编译参数

CMD=$1

if [ -z $CMD ] ; then
    CMD="help"
fi

if [ $CMD == "debug"   ] ; then build_cpp_debug   ; fi
if [ $CMD == "release" ] ; then build_cpp_release ; fi
if [ $CMD == "clean"   ] ; then build_cpp_clean   ; fi
