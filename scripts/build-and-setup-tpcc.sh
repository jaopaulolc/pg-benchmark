#!/usr/bin/env bash

function var-not-set-error() {
    local var=$1
    echo "error: '$var' not set! (did you forget to run setenv.sh?)"
    exit 1
}

if [[ -z "$PG_INSTALL_PATH" ]]; then
    var-not-set-error "PG_INSTALL_PATH"
fi

if [[ -z "$PG_DBS_PATH" ]]; then
    var-not-set-error "PG_DBS_PATH"
fi

if [[ -z "$TPCC_SRC_PATH" ]]; then
    var-not-set-error "TPCC_SRC_PATH"
fi

if [[ -z "$TPCC_INSTALL_PATH" ]]; then
    var-not-set-error "TPCC_INSTALL_PATH"
fi

SUFFIX="-no-ijit"
if [[ $1 ==  "ijit" ]]; then
  SUFFIX="-ijit"
fi

CPU=pwr8
if [[ ! -z $2 ]]; then
  CPU=$2
fi

set -x
DBPATH=$PG_DBS_PATH/tpcc/
TPCC_BIN=$TPCC_INSTALL_PATH/bin/
PG_PATH=${PG_INSTALL_PATH}${SUFFIX}-${CPU}
rm -rf $TPCC_INSTALL_PATH
mkdir -p $DBPATH

sed -e 's|^\(VARDIR\)|#\1|' \
    -e 's|^\(EXECDIR\)|#\1|' \
    -e 's|^\(export INCLUDEPATH =\).*|\1 $(PGINCLUDEPATH)|' \
    -e 's|^\(export LIBSPATH =\).*|\1 $(PGLIBPATH)|' \
    -i $TPCC_SRC_PATH/Makefile

make -C $TPCC_SRC_PATH clean \
     VARDIR=$DBPATH \
     EXECDIR=$TPCC_BIN \
     PGINCLUDEPATH=$PG_PATH/include/ \
     PGLIBPATH=$PG_PATH/lib/

make -C $TPCC_SRC_PATH \
     VARDIR=$DBPATH \
     EXECDIR=$TPCC_BIN \
     PGINCLUDEPATH=$PG_PATH/include/ \
     PGLIBPATH=$PG_PATH/lib/

make -C $TPCC_SRC_PATH install \
     VARDIR=$DBPATH \
     EXECDIR=$TPCC_BIN \
     PGINCLUDEPATH=$PG_PATH/include/ \
     PGLIBPATH=$PG_PATH/lib/
