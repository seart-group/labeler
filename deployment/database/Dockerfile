FROM postgres:18.1-alpine
LABEL maintainer="Ozren Dabić (dabico@usi.ch)"

ENV TZ=UTC \
    DATA_DIRECTORY=/docker-entrypoint-initdb.d

WORKDIR $DATA_DIRECTORY

COPY schema/01_definitions_schema.sql        \
     schema/02_definitions_function.sql      \
     schema/03_definitions_procedure.sql     \
     schema/04_definitions_view.sql          \
     schema/05_implementations_function.sql  \
     schema/06_implementations_procedure.sql \
     ./

COPY scripts/init-data.sh ./~init-data.sh

WORKDIR /

HEALTHCHECK \
  --start-period=60s \
  --interval=10s \
  --timeout=5s \
  --retries=5 \
CMD pg_isready -U $POSTGRES_USER -d $POSTGRES_DB
