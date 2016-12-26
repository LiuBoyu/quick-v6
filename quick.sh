#!/bin/bash

export QUICK=$(cd `dirname $0`; pwd)

export PROJCD=$2
export PROJNS=$3
export PROJPR=$4
export PROJCH=$5
export PROJID=$4-$5
export PROJPK=$6

function create()
{
    echo "create project $PROJCD $PROJNS $PROJPR-$PROJCH $PROJPK"

    cd    ..
    mkdir $PROJCD
    cd    $PROJCD

    mkdir res
    mkdir res/$PROJNS

    mkdir res.ext
    mkdir res.ext/$PROJNS-debug

    mkdir src
    mkdir src.ext

    mkdir proj
    mkdir bin

    ln -s ../../quick-v6/res.ext/framework-debug res.ext/framework-debug
    ln -s ../../quick-v6/src.ext/framework-debug src.ext/framework-debug
    ln -s ../../quick-v6/src/framework           src/framework

    cp -r ../quick-v6/src.ext/samples-debug src.ext/$PROJNS-debug
    cp -r ../quick-v6/src/samples           src/$PROJNS
    cp    ../quick-v6/src/main.lua          src
    cp    ../quick-v6/.gitignore            .

    mv src/$PROJNS/SPS-V6.lua src/$PROJNS/$PROJPR-$PROJCH.lua

    sed -i "" "s/PROJNS =.*/PROJNS = '$PROJNS'/g"                       src/main.lua
    sed -i "" "s/PROJID =.*/PROJID = '$PROJID'/g"                       src/main.lua

    sed -i "" "s/APP_ID      =.*/APP_ID      = '$PROJPK'/g"             src/$PROJNS/$PROJID.lua
    sed -i "" "s/APP_NAME    =.*/APP_NAME    = '$PROJID'/g"             src/$PROJNS/$PROJID.lua
    sed -i "" "s/APP_CODE    =.*/APP_CODE    = '$PROJID'/g"             src/$PROJNS/$PROJID.lua
    sed -i "" "s/APP_PRODUCT =.*/APP_PRODUCT = '$PROJPR'/g"             src/$PROJNS/$PROJID.lua
    sed -i "" "s/APP_CHANNEL =.*/APP_CHANNEL = '$PROJCH'/g"             src/$PROJNS/$PROJID.lua

    cd $QUICK
}

function android()
{
    echo "create android $PROJCD $PROJNS $PROJPR-$PROJCH $PROJPK"

    cd ../$PROJCD/proj

    if [ ! -d proj.android    ]; then
        mkdir proj.android
    fi

    cd    proj.android

    if [ ! -a .gitignore        ]; then
        cp ../../../quick-v6/proj/proj.android/.gitignore        .
    fi
    if [ ! -a gradle.properties ]; then
        cp ../../../quick-v6/proj/proj.android/gradle.properties .
    fi
    if [ ! -a build.gradle      ]; then
        cp ../../../quick-v6/proj/proj.android/build.gradle      .
    fi
    if [ ! -a settings.gradle   ]; then
        cp ../../../quick-v6/proj/proj.android/settings.gradle   .
        sed -i "" "s/SPS-V6/$PROJID/g" settings.gradle
    fi

    mkdir $PROJID

    cp ../../../quick-v6/proj/proj.android/SPS-V6/build.gradle       $PROJID
    cp ../../../quick-v6/proj/proj.android/SPS-V6/build.sh           $PROJID
    cp ../../../quick-v6/proj/proj.android/SPS-V6/proguard-rules.pro $PROJID
    cp ../../../quick-v6/proj/proj.android/SPS-V6/README.md          $PROJID
    cp ../../../quick-v6/proj/proj.android/SPS-V6/SPS-V6.txt         $PROJID/$PROJID.txt

    sed -i "" "s/'samples'/'$PROJNS'/g" $PROJID/build.gradle
    sed -i "" "s/SPS-V6/$PROJID/g"      $PROJID/build.gradle
    sed -i "" "s/SPS-V6/$PROJID/g"      $PROJID/README.md

    mkdir $PROJID/src
    mkdir $PROJID/src/debug
    mkdir $PROJID/src/debug/assets
    mkdir $PROJID/src/release
    mkdir $PROJID/src/release/assets

    ln -s ../../../../../../quick-v6/proj/proj.android/libs/libcocos2dx/jniLibs/debug   $PROJID/src/debug/jniLibs
    ln -s ../../../../../../quick-v6/proj/proj.android/libs/libcocos2dx/jniLibs/release $PROJID/src/release/jniLibs

    ln -s ../../../../../../res       $PROJID/src/debug/assets/res
    ln -s ../../../../../../res.ext   $PROJID/src/debug/assets/res.ext
    ln -s ../../../../../../src       $PROJID/src/debug/assets/src
    ln -s ../../../../../../src.ext   $PROJID/src/debug/assets/src.ext

    ln -s ../../../../../../res                                             $PROJID/src/release/assets/res
    cp -r ../../../quick-v6/proj/proj.android/SPS-V6/src/release/assets/src $PROJID/src/release/assets

    cp -r ../../../quick-v6/proj/proj.android/SPS-V6/src/main               $PROJID/src

    sed -i "" "s/org.cocos2dx.samplesv6/$PROJPK/g" $PROJID/build.gradle
    sed -i "" "s/org.cocos2dx.samplesv6/$PROJPK/g" $PROJID/src/main/AndroidManifest.xml
    sed -i "" "s/Samples V6/$PROJID/g"             $PROJID/src/main/res/values/strings.xml

    sed -i "" "s/org.cocos2dx.samplesv6/$PROJPK/g" $PROJID/src/main/java/org/cocos2dx/quickv6/MainActivity.java
    sed -i "" "s/samples/$PROJNS/g"                $PROJID/src/release/assets/src/main.lua
    sed -i "" "s/SPS-V6/$PROJID/g"                 $PROJID/src/release/assets/src/main.lua

    cd $PROJID
    keytool -genkey -keyalg RSA -keysize 1024 -validity 36500 -keystore $PROJID.keystore -storepass quickv6 -alias $PROJID -keypass quickv6 < $PROJID.txt
    cd ..

    cd $QUICK
}

function status()
{
    echo -e "[ \033[32mQUICKV6\033[0m ]"
    echo
    echo -e "./quick.sh  create pathname namespace product channel package"
    echo -e "./quick.sh  create battle-of-balls bob BOB CG org.cocos2dx.battleofballs"
    echo
    echo -e "./quick.sh android pathname namespace product channel package"
    echo -e "./quick.sh android battle-of-balls bob BOB CG org.cocos2dx.battleofballs"
}

case $1 in
    create)
        create
        ;;
    android)
        android
        ;;
    *)
        status
        ;;
esac
