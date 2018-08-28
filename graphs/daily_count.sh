#!/bin/bash

BASE_DIR=$(cd $(dirname $0); pwd)
VENV=${BASE_DIR}/.graphs

if [ ! -d $VENV ]; then
    python3 -mvenv $VENV
fi

source $VENV/bin/activate
pip install -r $BASE_DIR/requirements.txt

subunit2sql-graph --start-date 2018-03-01 --output ${BASE_DIR}/daily_count.png --config-file ${BASE_DIR}/subunit2sql.conf dailycount
