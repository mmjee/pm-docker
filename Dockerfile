FROM node:gallium-alpine AS build

WORKDIR /app/

ARG INSTANCE_URL
ARG EDS_URL
ARG PM_BRANCH=master

RUN --mount=type=cache,target=/var/cache/apk \
    apk add git
RUN git clone --depth 1 --branch $PM_BRANCH https://github.com/mmjee/Piped-Material.git .

ENV VUE_APP_PIPED_URL=${INSTANCE_URL}
ENV VUE_APP_EDS_URL=${EDS_URL}

RUN --mount=type=cache,target=/root/.cache/pnpm \
    --mount=type=cache,target=/app/node_modules \
    pnpm install --prefer-offline --fetch-timeout 1000000000 && \
    pnpm build

FROM nginx:alpine

COPY --from=build /app/dist/ /usr/share/nginx/html/
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
