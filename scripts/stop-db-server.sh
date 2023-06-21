#!/usr/bin/env bash

function var-not-set-error() {
    local var=$1
    echo "error: '$var' not set! (did you forget to run setenv.sh?)"
    exit 1
}

if [[ -z "$PG_DBS_PATH" ]]; then
    var-not-set-error "PG_DBS_PATH"
fi

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <db base dir name>"
  exit 1
fi

DBDATA=$PG_DBS_PATH/$1/data

pg_ctl -D $DBDATA stop
