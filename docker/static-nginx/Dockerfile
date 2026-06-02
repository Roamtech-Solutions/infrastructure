ARG NGINX_VERSION=stable-alpine

FROM nginx:${NGINX_VERSION}
ARG ENVIRONMENT
COPY . /usr/share/nginx/html
COPY ./docker/static-nginx/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
