#!/usr/bin/env bash

function var-not-set-error() {
    local var=$1
    echo "error: '$var' not set! (did you forget to run setenv.sh?)"
    exit 1
}

if [[ -z "$PG_DBS_PATH" ]]; then
    var-not-set-error "PG_DBS_PATH"
fi

if [[ -z "$TPCE_SRC_PATH" ]]; then
    var-not-set-error "TPCE_SRC_PATH"
fi

set -x
DBNAME=tpce
DBPATH=$PG_DBS_PATH/tpce
LOGDIR=$DBPATH/logs

PGPORTFILE=$DBPATH/postgres.port
if [[ ! -e $PGPORTFILE ]]; then
  echo "error: '$PGPORTFILE' does not exist! (did you forget to start the server?)"
  exit 1
fi
PGPORT=$(cat $PGPORTFILE)

pushd $UNIXODBC_SRC_PATH

./configure --prefix=$UNIXODBC_INSTALL_PATH
make 
make install

pushd $TPCE_SRC_PATH

CXX=g++

make -C prj/

./bin/EGenLoader -i flat_in -o flat_out -c 2000 -t 2000 -f 200 -w 50

DSS_DATA=$DBPATH/init-db-data
DSS_QUERIES=$DBPATH/benchmark-queries
DSS_QUERY_TEMPLATES=$DBPATH/query-templates
DSS_ANSWERS=$DBPATH/query-answers
mkdir -p $DSS_DATA
mkdir -p $DSS_QUERIES
mkdir -p $DSS_QUERY_TEMPLATES
mkdir -p $DSS_ANSWERS

popd

DB_CREATION_SQL=$DBPATH/creation-sql
mkdir -p $DB_CREATION_SQL
cp $TPCE_SQL_PATH/*.sql $DB_CREATION_SQL

createdb -p $PGPORT $DBNAME

psql -p $PGPORT $DBNAME < $DB_CREATION_SQL/1_create_table.sql \
     > $LOGDIR/setup1.log \
     2> $LOGDIR/setup1.err

psql -p $PGPORT $DBNAME < $DB_CREATION_SQL/2_load_data.sql \
     > $LOGDIR/setup2.log \
     2> $LOGDIR/setup2.err

psql -p $PGPORT $DBNAME < $DB_CREATION_SQL/3_create_keys.sql \
     > $LOGDIR/setup3.log \
     2> $LOGDIR/setup3.err

psql -p $PGPORT $DBNAME < $DB_CREATION_SQL/4_create_fk_index.sql \
     > $LOGDIR/setup4.log \
     2> $LOGDIR/setup4.err

psql -p $PGPORT $DBNAME < $DB_CREATION_SQL/5_create_index.sql \
     > $LOGDIR/setup5.log \
     2> $LOGDIR/setup5.err

psql -p $PGPORT $DBNAME < $DB_CREATION_SQL/6_create_sequence.sql \
     > $LOGDIR/setup6.log \
     2> $LOGDIR/setup6.err

psql -p $PGPORT $DBNAME < $DB_CREATION_SQL/7_analyze_table.sql \
     > $LOGDIR/setup7.log \
     2> $LOGDIR/setup7.err
