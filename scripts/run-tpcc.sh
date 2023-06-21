#!/usr/bin/env bash

function var-not-set-error() {
    local var=$1
    echo "error: '$var' not set! (did you forget to run setenv.sh?)"
    exit 1
}

if [[ -z "$TPCC_INSTALL_PATH" ]]; then
    var-not-set-error "TPCC_INSTALL_PATH"
fi

if [[ -z "$PG_DBS_PATH" ]]; then
    var-not-set-error "PG_DBS_PATH"
fi

PGPORTFILE=$PG_DBS_PATH/tpcc/postgres.port
if [[ ! -e $PGPORTFILE ]]; then
  echo "error: '$PGPORTFILE' does not exist! (did you forget to start the server?)"
  exit 1
fi
PGPORT=$(cat "$PGPORTFILE")

export PGPORT

cd "$PG_DBS_PATH/tpcc" || (echo "error: '$PG_DBS_PATH/tpcc' does not exist!" && exit 1)
"$TPCC_INSTALL_PATH/bin/bench"
