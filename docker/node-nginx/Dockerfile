ARG NODE_VERSION=24
ARG NODE_BUILD_DIR=dist

FROM node:${NODE_VERSION}-alpine as build
ARG ENVIRONMENT
ARG NODE_BUILD_DIR=dist
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
ENV NODE_ENV=${ENVIRONMENT}
ENV BUILD_PATH=${NODE_BUILD_DIR}
RUN npm run build

FROM nginx:stable-alpine as production
ARG NODE_BUILD_DIR
COPY --from=build /app/${NODE_BUILD_DIR} /usr/share/nginx/html
COPY ./docker/node-nginx/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

