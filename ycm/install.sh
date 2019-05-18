#!/bin/bash
#
# @author   Solomon Ng <solomon.wzs@gmail.com>
# @date     2019-05-12
# @version  1.0
# @license  MIT


function f_readlink() {
    TARGET_FILE=$1

    cd "$(dirname "$TARGET_FILE")" || exit
    TARGET_FILE=$(basename "$TARGET_FILE")

    # Iterate down a (possible) chain of symlinks
    while [ -L "$TARGET_FILE" ]
    do
        TARGET_FILE=$(readlink "$TARGET_FILE")
        cd "$(dirname "$TARGET_FILE")" || exit
        TARGET_FILE=$(basename "$TARGET_FILE")
    done

    # Compute the canonicalized name by finding the physical path
    # for the directory we're in and appending the target file.
    PHYS_DIR=$(pwd -P)
    RESULT=$PHYS_DIR/$TARGET_FILE
    echo "$RESULT"
}

EXECUTE_FILENAME=$(f_readlink "$0")
EXECUTE_DIRNAME=$(dirname "$EXECUTE_FILENAME")

ycm_dir="$EXECUTE_DIRNAME/../bundle/YouCompleteMe"

cd "$ycm_dir" || exit
git submodule update --init --recursive
python3 install.py --go-completer --rust-completer --clang-completer --ts-completer

# build_path="$EXECUTE_DIRNAME/ycmd_build"
# [ -d "$build_path" ] && rm -rf "$build_path"
# mkdir "$build_path"
# cd "$build_path" || exit

# cmake -G "Unix Makefiles" \
#     -DUSE_CLANG_COMPLETER=ON \
#     -DUSE_PYTHON2=OFF \
#     -DPYTHON_INCLUDE_DIR="/usr/local/Frameworks/Python.framework/Versions/3.7/include/python3.7m" \
#     -DPYTHON_LIBRARY="/usr/local/Frameworks/Python.framework/Versions/3.7/lib/libpython3.7.dylib" \
#     . "$ycm_dir/third_party/ycmd/cpp"

# cmake --build . --target ycm_core
