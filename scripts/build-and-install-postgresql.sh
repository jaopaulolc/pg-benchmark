#!/usr/bin/env bash

function var-not-set-error() {
    local var=$1
    echo "error: '$var' not set! (did you forget to run setenv.sh?)"
    exit 1
}

if [[ -z "$LLVM_PATH" ]]; then
    var-not-set-error "LLVM_PATH"
fi

if [[ -z "$PG_SRC_PATH" ]]; then
    var-not-set-error "PG_SRC_PATH"
fi

if [[ -z "$PG_INSTALL_PATH" ]]; then
    var-not-set-error "PG_INSTALL_PATH"
fi

CPU=native
if [[ ! -z $2 ]]; then
  CPU=$2
fi

LLVM_BIN_PATH="$LLVM_PATH/bin"
CFLAGS="-O3 -g -mcpu=$CPU"
CXXFLAGS="-O3 -g -mcpu=$CPU"
CONFIGUREFLAGS="--with-llvm"

set -x
builddir=$PG_SRC_PATH/build
rm -rf $builddir
mkdir $builddir
cd $builddir
if [[ ! $? -eq 0 ]]; then
    exit 1
fi

../configure \
  --prefix=${PG_INSTALL_PATH}-${CPU} \
  $CONFIGUREFLAGS \
  CC=$LLVM_BIN_PATH/clang \
  CXX=$LLVM_BIN_PATH/clang++ \
  LLVM_CONFIG=$LLVM_BIN_PATH/llvm-config \
  CLANG=$LLVM_BIN_PATH/clang \
  CFLAGS="$CFLAGS" \
  CXXFLAGS="$CXXFLAGS" \
  LDFLAGS="$LDFLAGS"

make -j16 && make -j16 check && make -j16 install
