#!/usr/bin/env bash

# customize this variables
REPO_ROOT="$PWD"
LLVM_PATH="__PLEASE_DEFINE_ME__"
##########################

PG_SRC_PATH="$REPO_ROOT/srcs/postgresql"
PG_INSTALL_PATH="$REPO_ROOT/postgresql-install"
PG_DBS_PATH=$REPO_ROOT/databases
TPCH_SRC_PATH=$REPO_ROOT/srcs/tpc-h-v3.0.1/dbgen
TPCH_SQL_CREATION=$REPO_ROOT/srcs/tpch-sql-creation

TPCC_SRC_PATH=$REPO_ROOT/srcs/tpccuva-1.2.4
TPCC_INSTALL_PATH=$REPO_ROOT/tpcc-install

TPCE_SRC_PATH=$REPO_ROOT/srcs/tpc-e-tool
TPCE_SQL_PATH=$REPO_ROOT/srcs/tpc-e-scripts

UNIXODBC_SRC_PATH=$REPO_ROOT/srcs/unixODBC-2.3.11
UNIXODBC_INSTALL_PATH=$REPO_ROOT/srcs/unixODBC-install

PATH=`sed 's|'$LLVM_PATH'[^:]\+:||g' <<<$PATH`
LD_LIBRARY_PATH=`sed 's|'$LLVM_PATH'[^:]\+:||g' <<<$LD_LIBRARY_PATH`
LD_LIBRARY_PATH=`sed 's|'$READLINE_PATH'[^:]\+:||g' <<<$LD_LIBRARY_PATH`

# for some reason initdb does not like the machine's locale
unset LC_ALL
unset LC_CTYPE

LD_LIBRARY_PATH=$READLINE_PATH/lib:$LD_LIBRARY_PATH
LD_LIBRARY_PATH=$LLVM_PATH/lib:$LD_LIBRARY_PATH

PATH=$LLVM_PATH/bin:$PATH

export LD_LIBRARY_PATH PATH LLVM_PATH
export PG_SRC_PATH PG_INSTALL_PATH PG_DBS_PATH
export TPCH_SRC_PATH TPCH_SQL_CREATION TPCC_SRC_PATH TPCC_INSTALL_PATH TPCE_SRC_PATH TPCE_SQL_PATH UNIXODBC_SRC_PATH UNIXODBC_INSTALL_PATH
