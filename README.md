# Labeler

## Usage

To get started with the labeler, you'll need to define the following environment variables in a `.env` file:

```dotenv
COMPOSE_PROJECT_NAME=labeling

DATABASE_NAME=labeling
DATABASE_USER=labeling_admin
DATABASE_PASS=Ex4mpleP4$$w0rd
```

After that define the following files:

1. `label.txt` - A file containing the labels to be used in the labeling process, one label per line.
2. `reviewer.txt` - A file containing the reviewers to be used in the labeling process, one reviewer name per line.
3. `instance.[ct]sv` - A file containing the instances to be labeled, one instance per line.
   The file must adhere to the following format: `instance_category<SEPARATOR>instance_json`.
   If you are using a `.tsv` file, the separator is `\t`, while for `.csv` files the separator is `,`.
   Only one of these files should be defined, and if both are defined, the `.tsv` file will take precedence.

Finally, create a `docker-compose.yml` file with the following configurations:

```yaml
version: "3.9"
name: "labeling"

services:

  labeling-database:
    container_name: labeling-database
    hostname: labeling-database
    image: seart/labeling-database:latest
    volumes:
      - data:/var/lib/postgresql/data
      - ./label.txt:/docker-entrypoint-initdb.d/label.txt
      - ./reviewer.txt:/docker-entrypoint-initdb.d/reviewer.txt
      - ./instance.tsv:/docker-entrypoint-initdb.d/instance.tsv
    networks: [ default ]
    environment:
      POSTGRES_DB: ${DATABASE_NAME}
      POSTGRES_USER: ${DATABASE_USER}
      POSTGRES_PASSWORD: ${DATABASE_PASS}
    restart: always
    labels:
       - "com.centurylinklabs.watchtower.scope=labeler"
    
  labeling-server:
    container_name: labeling-server
    hostname: labeling-server
    image: seart/labeling-server:latest
    environment:
      DATABASE_HOST: labeling-database
      DATABASE_PORT: 5432
      DATABASE_NAME: ${DATABASE_NAME}
      DATABASE_USER: ${DATABASE_USER}
      DATABASE_PASS: ${DATABASE_PASS}
    depends_on:
      labeling-database:
        condition: service_healthy
    deploy:
      restart_policy:
        condition: on-failure
        max_attempts: 3
    labels:
       - "com.centurylinklabs.watchtower.scope=labeler"
    ports:
      - "7755:3000"
        
  # Optional service for backing up the
  # database at the start of each day
  labeling-backup:
    container_name: labeling-backup
    hostname: labeling-backup
    image: tiredofit/db-backup:latest
    volumes:
      - /tmp/labeling/backup:/backup
    networks: [ default ]
    links: [ labeling-database ]
    environment:
      TZ: UTC
      DB01_TYPE: pgsql
      DB01_HOST: labeling-database
      DB01_NAME: ${DATABASE_NAME}
      DB01_USER: ${DATABASE_USER}
      DB01_PASS: ${DATABASE_PASS}
      DEFAULT_BACKUP_BEGIN: '0000'
      DEFAULT_CLEANUP_TIME: '10080'
      DEFAULT_EXTRA_BACKUP_OPTS: --data-only
      DEFAULT_COMPRESSION: GZ
      DEFAULT_CHECKSUM: SHA1
      DEFAULT_CREATE_LATEST_SYMLINK: FALSE
      CONTAINER_ENABLE_MONITORING: FALSE
      CONTAINER_ENABLE_MESSAGING: FALSE
    depends_on:
      labeling-database:
        condition: service_healthy
    restart: always
    labels:
      - "com.centurylinklabs.watchtower.scope=labeler"
    
  # Optional service for updating the
  # service images at the start of each hour
  labeling-watchtower:
    container_name: labeling-watchtower
    hostname: labeling-watchtower
    image: containrrr/watchtower:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    networks: [ default ]
    environment:
      WATCHTOWER_SCOPE: 'labeler'
      WATCHTOWER_TIMEOUT: '60s'
      WATCHTOWER_SCHEDULE: '0 0 */1 * * *'
      WATCHTOWER_INCLUDE_STOPPED: true
    depends_on:
      labeling-database:
        condition: service_healthy
      labeling-server:
        condition: service_healthy
      labeling-backup:
        condition: service_started
    restart: always
    labels:
      - "com.centurylinklabs.watchtower.scope=labeler"

volumes:
  data:
    name: labeling-data

networks:
  default:
    name: labeling-network
```
