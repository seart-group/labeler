FROM postgres:16.1-alpine

WORKDIR /docker-entrypoint-initdb.d

COPY schema/01_schema.sql     \
     schema/02_views.sql      \
     schema/03_functions.sql  \
     schema/04_procedures.sql \
     ./

WORKDIR /

# TODO: The Postgres image limits permissions for the initializtion scripts.
#       Therefore, if you need to fetch any external resources,
#       install packages or run other system commands,
#       you must do so here at build time.
