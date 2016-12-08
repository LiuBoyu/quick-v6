#!/bin/bash

export QUICK=$(cd `dirname $0`; pwd)

export PROJCD=$2
export PROJNS=$3
export PROJPR=$4
export PROJCH=$5

function create()
{
    echo "create project $PROJCD $PROJNS $PROJPR-$PROJCH"

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

    sed -i '' 's/PROJNS =.*/PROJNS = "'"$PROJNS"'"/g'                       src/main.lua
    sed -i '' 's/PROJID =.*/PROJID = "'"$PROJPR"'-'"$PROJCH"'"/g'           src/main.lua

    sed -i '' 's/APP_ID      =.*/APP_ID      = "'"$PROJCD"'"/g'             src/$PROJNS/$PROJPR-$PROJCH.lua
    sed -i '' 's/APP_NAME    =.*/APP_NAME    = "'"$PROJCD"'"/g'             src/$PROJNS/$PROJPR-$PROJCH.lua
    sed -i '' 's/APP_CODE    =.*/APP_CODE    = "'"$PROJPR"'-'"$PROJCH"'"/g' src/$PROJNS/$PROJPR-$PROJCH.lua
    sed -i '' 's/APP_PRODUCT =.*/APP_PRODUCT = "'"$PROJPR"'"/g'             src/$PROJNS/$PROJPR-$PROJCH.lua
    sed -i '' 's/APP_CHANNEL =.*/APP_CHANNEL = "'"$PROJCH"'"/g'             src/$PROJNS/$PROJPR-$PROJCH.lua
}

function status()
{
    echo -e "[ \033[32mQUICKV6\033[0m ]"
    echo -e "./quick.sh create pathname namespace product channel"
    echo -e "./quick.sh create battle-of-balls bob BOB CG"
}

case $1 in
    create)
        create
        ;;
    *)
        status
        ;;
esac
