FROM postgres:16.2-alpine
LABEL maintainer="Ozren Dabić (dabico@usi.ch)"
LABEL com.centurylinklabs.watchtower.scope="labeler"

ENV DATA_DIRECTORY=/docker-entrypoint-initdb.d \
    TZ=UTC

WORKDIR $DATA_DIRECTORY

COPY schema/01_schema.sql     \
     schema/02_views.sql      \
     schema/03_functions.sql  \
     schema/04_procedures.sql \
     ./

COPY scripts/init-data.sh ./~init-data.sh

WORKDIR /

HEALTHCHECK \
  --start-period=60s \
  --interval=10s \
  --timeout=5s \
  --retries=5 \
CMD pg_isready -U $POSTGRES_USER -d $POSTGRES_DB
