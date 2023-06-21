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

DBPATH=$PG_DBS_PATH/tpch

PGPORTFILE=$DBPATH/postgres.port
if [[ ! -e $PGPORTFILE ]]; then
  echo "error: '$PGPORTFILE' does not exist! (did you forget to start the server?)"
  exit 1
fi

pushd "$TPCE_SRC_PATH" || (echo "error: '$TPCE_SRC_PATH' does not exist!" && exit 1)

LD_LIBRARY_PATH=$UNIXODBC_INSTALL_PATH/lib:$LD_LIBRARY_PATH
./bin/EGenSimpleTest -c 2000 -a 2000 -f 200 -d 50 -l 200 -e ../flat_in -t 30 -r 10 -u 2
