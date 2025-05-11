FROM alpine:3.21.3

RUN apk update && apk add --no-cache nginx && \
    mkdir -p /etc/nginx/ssl /usr/share/nginx/html && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

COPY certs/nginx.crt certs/nginx.key /etc/nginx/ssl/
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
