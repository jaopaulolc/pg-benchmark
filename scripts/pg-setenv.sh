#!/usr/bin/env bash

function var-not-set-error() {
    local var=$1
    echo "error: '$var' not set! (did you forget to run setenv.sh?)"
    exit 1
}

if [[ -z "$PG_SRC_PATH" ]]; then
    var-not-set-error "PG_SRC_PATH"
fi

if [[ -z "$PG_INSTALL_PATH" ]]; then
    var-not-set-error "PG_INSTALL_PATH"
fi

CPU="native"
if [[ -n $1 ]]; then
  CPU=$1
fi

pg_prefix=$PG_INSTALL_PATH
PG_PATH=${PG_INSTALL_PATH}-${CPU}

# remove previous pg path from PATH
PATH=`sed 's|'$pg_prefix'[^:]\+:||g' <<<$PATH`
LD_LIBRARY_PATH=`sed 's|'$pg_prefix'[^:]\+:||g' <<<$LD_LIBRARY_PATH`

PATH=$PG_PATH/bin:$PATH
LD_LIBRARY_PATH=$PG_PATH/lib:$LD_LIBRARY_PATH
export PATH LD_LIBRARY_PATH
