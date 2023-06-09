FROM node:lts-alpine

WORKDIR /labeling

COPY . .

ARG DATABASE_NAME
ARG DATABASE_USER
ARG DATABASE_PASS
ARG DATABASE_PORT
ARG NODE_ENV=production

RUN apk update && apk add --no-cache gettext
RUN envsubst < .env.template > .env
RUN npm install

CMD ["npm", "run", "start"]
