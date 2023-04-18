FROM node:lts-alpine AS build

WORKDIR /app/

RUN --mount=type=cache,target=/var/cache/apk \
    apk add git
RUN git clone --depth 1 https://github.com/mmjee/Piped-Material.git .
ARG INSTANCE_URL
ENV VUE_APP_PIPED_URL=${INSTANCE_URL}

COPY ./22.diff .
RUN git apply 22.diff

RUN --mount=type=cache,target=/root/.cache/yarn \
    --mount=type=cache,target=/app/node_modules \
    yarn install --prefer-offline --network-timeout 1000000000 && \
    yarn build

FROM nginx:alpine

COPY --from=build /app/dist/ /usr/share/nginx/html/
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
