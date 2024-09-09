FROM node:22.8.0-alpine AS build

WORKDIR /build

COPY public public/
COPY routes routes/
COPY util util/
COPY views views/
COPY index.js          \
     package.json      \
     package-lock.json \
     ./

RUN apk update --quiet && \
    apk add --quiet --no-cache \
        gettext=~0.22.5 \
        moreutils=~0.69 && \
    npm ci --quiet && \
    npm run --silent minify && \
    rm -rf node_modules

FROM node:22.8.0-alpine
LABEL maintainer="Ozren Dabić (dabico@usi.ch)"

ENV TZ=UTC \
    NODE_ENV=production

WORKDIR /labeling

COPY --from=build build .

RUN apk update --quiet && \
    apk add --quiet --no-cache \
        curl=~8.9.1 \
        jq=~1.7.1 && \
    npm ci --quiet

HEALTHCHECK \
  --start-period=15s \
  --interval=60s \
  --timeout=5s \
  --retries=5 \
CMD curl --silent --fail --request GET http://localhost:3000/actuator/health | \
    jq --exit-status -n 'inputs | if has("status") then .status=="UP" else false end' > /dev/null || exit 1

CMD ["npm", "run", "start"]
