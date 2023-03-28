# FROM node:16-alpine AS deps
FROM node:alpine AS deps

# https://github.com/nodejs/docker-node/issues/282
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY package.json package-lock.json ./

# Installing npm deps
RUN npm i --quiet
# RUN npm ci --omit=dev

# FROM node:16-alpine AS build
FROM node:16-slim AS build

COPY --from=deps /usr/src/app /usr/src/app

WORKDIR /usr/src/app

# Bundle app source
COPY ./ /usr/src/app

# To jest potrzebne zeby webpack przepuscil bledy podczas transpilacji typesctipta

# RUN printf '%s\n' > .env \
# 'TSC_COMPILE_ON_ERROR=true' \
# 'ESLINT_NO_DEV_ERRORS=true'

RUN npm run build

FROM nginx:1.21.6-alpine
# FROM nginx:1.22

WORKDIR /var/www

# ARG APP_VERSION
# ENV REACT_APP_VERSION=$APP_VERSION

# ARG API_URL
# ENV REACT_APP_API_URL=$API_URL

# ARG DEFAULT_HES_ID
# ENV REACT_APP_DEFAULT_HES_ID=$DEFAULT_HES_ID

# COPY docker/20-patch-index.sh /docker-entrypoint.d
COPY templates/default.conf /etc/nginx/conf.d
RUN rm -rf /etc/nginx/sites-enabled/default
# RUN chmod a+x /docker-entrypoint.d/*.sh

COPY --from=build /usr/src/app/build /var/www

EXPOSE 80
