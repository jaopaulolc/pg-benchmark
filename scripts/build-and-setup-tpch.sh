#!/usr/bin/env bash

function var-not-set-error() {
    local var=$1
    echo "error: '$var' not set! (did you forget to run setenv.sh?)"
    exit 1
}

if [[ -z "$PG_DBS_PATH" ]]; then
    var-not-set-error "PG_DBS_PATH"
fi

if [[ -z "$TPCH_SRC_PATH" ]]; then
    var-not-set-error "TPCH_SRC_PATH"
fi

set -x
DBNAME=tpch
DBPATH=$PG_DBS_PATH/tpch
LOGDIR=$DBPATH/logs

PGPORTFILE=$DBPATH/postgres.port
if [[ ! -e $PGPORTFILE ]]; then
  echo "error: '$PGPORTFILE' does not exist! (did you forget to start the server?)"
  exit 1
fi
PGPORT=$(cat $PGPORTFILE)

pushd $TPCH_SRC_PATH

patch -f < $TPCH_SRC_PATH/../../tpcd.h.patch
patch -f < $TPCH_SRC_PATH/../../qgen.c.patch
patch -f -p1 < $TPCH_SRC_PATH/../../1.sql.patch
cp makefile.suite Makefile
sed 's|^CC\s\+\?=\s\+\?|CC = clang|' -i Makefile
sed 's|^DATABASE\s\+\?=\s\+\?|DATABASE = POSTGRESQL|' -i Makefile
sed 's|^MACHINE\s\+\?=\s\+\?|MACHINE = LINUX|' -i Makefile
sed 's|^WORKLOAD\s\+\?=\s\+\?|WORKLOAD = TPCH|' -i Makefile

make clean
make

DSS_DATA=$DBPATH/init-db-data
DSS_QUERIES=$DBPATH/benchmark-queries
DSS_QUERY_TEMPLATES=$DBPATH/query-templates
DSS_ANSWERS=$DBPATH/query-answers
mkdir -p $DSS_DATA
mkdir -p $DSS_QUERIES
mkdir -p $DSS_QUERY_TEMPLATES
mkdir -p $DSS_ANSWERS

DSS_PATH=$DSS_DATA ./dbgen -s 1
# change for from tbl to csv
for f in `ls $DSS_DATA/*.tbl`; do
    sed 's/|$//' $f > ${f/tbl/csv};
    echo $f;
done;

for q in `seq 1 22`; do
    # ajust template queries to remove end of stmt ';'
    qfile="./queries/${q}.sql"
    nlines=`wc -l < $qfile`
    sed $((nlines-1))',/;/{s|;\s\+\?$||}' $qfile > $DSS_QUERY_TEMPLATES/${q}.sql
    DSS_QUERY=$DSS_QUERY_TEMPLATES \
        DSS_CONFIG=. ./qgen -v -d -s 1 $q > $DSS_QUERIES/$q.sql
    qans=$DSS_ANSWERS/q${q}.out
    # copy query answers
    cp ./answers/q${q}.out $qans
    # remove spaces around column separators
    sed -i 's/\s\+\?|\s\+\?/|/g' $qans
    # remove trailing spaces
    sed -i 's/\s\+\?$//' $qans
    # remove leading spaces
    sed -i 's/^\s\+\?//' $qans
    # delete column names row
    sed -i '1d' $qans
done

popd

DB_CREATION_SQL=$DBPATH/creation-sql
mkdir -p $DB_CREATION_SQL
cp $TPCH_SQL_CREATION/*.sql $DB_CREATION_SQL
sed 's|##TBLPATH##|'$DSS_DATA'|' -i $DB_CREATION_SQL/create-and-load-tables.sql

createdb -p $PGPORT $DBNAME

psql -p $PGPORT postgres -c "select name,setting from pg_settings" \
     > $LOGDIR/settings.log \
     2> $LOGDIR/settings.err


psql -p $PGPORT $DBNAME < $DB_CREATION_SQL/create-and-load-tables.sql \
     > $LOGDIR/load.log \
     2> $LOGDIR/load.err

psql -p $PGPORT $DBNAME < $DB_CREATION_SQL/pkeys.sql \
     > $LOGDIR/pkeys.log \
     2> $LOGDIR/pkeys.err

psql -p $PGPORT $DBNAME < $DB_CREATION_SQL/alter.sql \
     > $LOGDIR/alter.log \
     2> $LOGDIR/alter.err

psql -p $PGPORT $DBNAME < $DB_CREATION_SQL/index.sql \
     > $LOGDIR/index.log \
     2> $LOGDIR/index.err

psql -p $PGPORT $DBNAME -c "analyze" \
     > $LOGDIR/analyze.log \
     2> $LOGDIR/analyze.err
