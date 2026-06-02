ARG NGINX_VERSION=stable-alpine

FROM nginx:${NGINX_VERSION}
ARG ENVIRONMENT
COPY . /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
