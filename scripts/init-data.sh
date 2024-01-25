#!/bin/bash

# If you want to specify the starting labels and reviewers,
# you must edit the two respective text files.
# Keep in mind that entries should be newline separated, and lower-cased.
# By default, these files are completely empty,
# meaning that the database will not contain any data by default.
# To import instances, you must add an instance.{csv,tsv} file using a bind mount.

set -e

function exec_cmd() {
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c "$1"
}

if [ -f "/docker-entrypoint-initdb.d/label.txt" ];
then exec_cmd "\COPY label(name) FROM '/docker-entrypoint-initdb.d/label.txt';";
fi

if [ -f "/docker-entrypoint-initdb.d/reviewer.txt" ];
then exec_cmd "\COPY reviewer(name) FROM '/docker-entrypoint-initdb.d/reviewer.txt';";
fi

if [ -f "/docker-entrypoint-initdb.d/instance.csv" ];
then exec_cmd "\COPY instance(category, data) FROM '/docker-entrypoint-initdb.d/instance.csv' DELIMITER E',' QUOTE E'\b' CSV;";
elif [ -f "/docker-entrypoint-initdb.d/instance.tsv" ];
then exec_cmd "\COPY instance(category, data) FROM '/docker-entrypoint-initdb.d/instance.tsv' DELIMITER E'\t' QUOTE E'\b' CSV;";
fi
