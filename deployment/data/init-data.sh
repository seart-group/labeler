#!/bin/bash

# TODO: By default, these files are completely empty.
#       If you want to specify the starting labels and reviewers,
#       you must edit the two respective text files.
#       Keep in mind that these two files should be newline separated.
#       Furthermore, we recommend all data be in lower-cased.
#       To import instances, you must first decide on how and when they should be loaded.
#       Either add them to the container using a bind mount,
#       or do so at build time (refer to the `server` Dockerfile for more details).
#       After that, use a \COPY command similar to the ones shown in the file.

set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
  -c "\COPY label(name) FROM '/docker-entrypoint-initdb.d/label.txt';"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
  -c "\COPY reviewer(name) FROM '/docker-entrypoint-initdb.d/reviewer.txt';"
