FROM node:hydrogen-alpine AS build

WORKDIR /app/

ARG INSTANCE_URL
ARG EDS_URL
ARG PM_BRANCH=master

RUN --mount=type=cache,target=/var/cache/apk \
    apk add git
RUN git clone --depth 1 --branch $PM_BRANCH https://github.com/mmjee/Piped-Material.git .

ENV VUE_APP_PIPED_URL=${INSTANCE_URL}
ENV VUE_APP_EDS_URL=${EDS_URL}

RUN --mount=type=cache,target=/root/.cache/yarn \
    --mount=type=cache,target=/app/node_modules \
    yarn install --prefer-offline --network-timeout 1000000000 && \
    yarn build

FROM nginx:alpine

COPY --from=build /app/dist/ /usr/share/nginx/html/
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
