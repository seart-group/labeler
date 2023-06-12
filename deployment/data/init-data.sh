#!/bin/bash

# TODO: By default, these files are completely empty.
#       If you want to specify the starting labels and reviewers,
#       you must edit the two respective text files.
#       Keep in mind that entries should be newline separated, and lower-cased.
#       To import instances, you must first decide how and when the files should be added.
#       Either add them to the container using a bind mount, or do so on image build.
#       After that, use a \COPY command similar to the ones shown in the file.

set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
  -c "\COPY label(name) FROM '/docker-entrypoint-initdb.d/label.txt';"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
  -c "\COPY reviewer(name) FROM '/docker-entrypoint-initdb.d/reviewer.txt';"
