#!/bin/bash

# If you want to specify the starting labels and reviewers,
# you must edit the two respective text files.
# Keep in mind that entries should be newline separated, and lower-cased.
# By default, these files are completely empty,
# meaning that the database will not contain any data by default.
# To import instances, you must add an instance.{csv,tsv} file using a bind mount.

set -e

DATA_DIRECTORY=${DATA_DIRECTORY:-$PWD}
DATA_LABEL="$DATA_DIRECTORY/label.txt"
DATA_REVIEWER="$DATA_DIRECTORY/reviewer.txt"
DATA_INSTANCE="$DATA_DIRECTORY/instance"
DATA_INSTANCE_CSV="$DATA_INSTANCE.csv"
DATA_INSTANCE_TSV="$DATA_INSTANCE.tsv"

function exec_cmd() {
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c "$1"
}

if [ -f "$DATA_LABEL" ];
then exec_cmd "\COPY label(name) FROM '$DATA_LABEL';";
fi

if [ -f "$DATA_REVIEWER" ];
then exec_cmd "\COPY reviewer(name) FROM '$DATA_REVIEWER';";
fi

if [ -f "$DATA_INSTANCE_CSV" ];
then exec_cmd "\COPY instance(category, data) FROM '$DATA_INSTANCE_CSV' DELIMITER E',' QUOTE E'\b' CSV;";
elif [ -f "$DATA_INSTANCE_TSV" ];
then exec_cmd "\COPY instance(category, data) FROM '$DATA_INSTANCE_TSV' DELIMITER E'\t' QUOTE E'\b' CSV;";
fi
