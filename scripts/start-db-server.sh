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

DBPATH=$PG_DBS_PATH/$1
DBDATA=$DBPATH/data
LOGDIR=$DBPATH/logs

if [[ -e $DBDATA ]]; then
    echo "Directory '$DBDATA' exists."
    echo "If you proceed '$DBPATH' will be deleted."
    echo -n "Do you want to proceed? (y/n): "
    read answer
    if [[ ! "$answer" == "y" ]]; then
        echo -e "\nAborting...";
        exit 1
    fi
    pg_ctl -D $DBDATA stop
    echo -en "\nDo you want reuse '$DBDATA' directory ? (y/n): "
    read answer
    if [[ ! "$answer" == "y" ]]; then
        rm -rf $DBPATH
    fi
fi

mkdir -p $DBDATA
mkdir -p $LOGDIR

# avoid colisions with other users
PGPORT=54$(( RANDOM % 68 + 32 ))
echo $PGPORT > $DBPATH/postgres.port

initdb -D $DBDATA
PGPORT=$PGPORT \
  pg_ctl -D $DBDATA \
         -l $LOGDIR/db-start.log \
  start
