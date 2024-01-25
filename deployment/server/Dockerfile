FROM node:20.11.0-alpine AS build

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
        gettext=~0.22.3 \
        moreutils=~0.68 && \
    npm ci --quiet && \
    npm run --silent minify && \
    rm -rf node_modules

FROM node:20.11.0-alpine

ENV NODE_ENV=production

WORKDIR /labeling

COPY --from=build build .

RUN npm ci --quiet

CMD ["npm", "run", "start"]
