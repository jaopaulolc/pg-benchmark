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
PGPORT=$(cat "$PGPORTFILE")

QUERIES_PATH="$DBPATH/benchmark-queries"
QUERIES_ANSWERS="$DBPATH/query-answers"
QUERIES_OUTPUT="$DBPATH/query-output"
mkdir -p "$QUERIES_OUTPUT"

for i in $(seq 1 22); do
    qout="$QUERIES_OUTPUT/q${i}.out"
    qans="$QUERIES_ANSWERS/q${i}.out"
    echo "Running ${i}.sql..."
    tmpfile=$(mktemp)
    psql -p "$PGPORT" tpch -q \
         -t \
         -c '\timing on' \
         -c '\o '"$tmpfile" \
         -c '\i '"$QUERIES_PATH/${i}.sql"
    #remove trailing spaces
    sed -i 's/\s\+\?$//' "$tmpfile"
    # remove spaces between column separator
    sed -i 's/\s\+\?|\s\+\?/|/g' "$tmpfile"
    # remove leading spaces
    sed -i 's/^\s\+\?//' "$tmpfile"
    # delete last line
    sed -i '"$d"' "$tmpfile"
    # format floating-point number with 2 decimal places
    awk -f scripts/filter.awk "$tmpfile" > "$qout"
    rm -f "$tmpfile"
    diff -q -s "$qout" "$qans"
done
