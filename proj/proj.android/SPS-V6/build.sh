#!/bin/bash

PROJ=$(cd `dirname $0`; pwd)

# 编译参数

echo "==================================="
echo "========[Build Lua Release]========"
echo "==================================="

export QUICK_V3_ROOT="../../../../quick-v3"

COMP="$QUICK_V3_ROOT/quick/bin/compile_scripts.sh"
OPTS="-e xxtea_zip -ek $2 -es XT"

$COMP $OPTS -jit -r -i ../../../src/framework  -p framework  -o src/release/assets/zip/framework.zip
$COMP $OPTS -jit -r -i ../../../src/$1         -p $1         -o src/release/assets/zip/$1.zip

