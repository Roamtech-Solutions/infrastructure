ARG NODE_VERSION=24
ARG NODE_BUILD_DIR=dist

FROM node:${NODE_VERSION}-alpine as build
ARG ENVIRONMENT
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
ENV NODE_ENV=${ENVIRONMENT}
RUN npm run build

FROM nginx:stable-alpine as production
COPY --from=build /app/${NODE_BUILD_DIR} /usr/share/nginx/html
COPY ./docker/node-nginx/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

