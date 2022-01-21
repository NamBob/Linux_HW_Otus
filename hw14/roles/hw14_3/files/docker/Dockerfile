FROM alpine

VOLUME /sys/fs/cgroup
#VOLUME /www/html

RUN apk update; \
    apk add nginx bash openrc curl; \
    mkdir -p /run/openrc; \
    touch /run/openrc/softlevel; \
    /sbin/openrc 2>/dev/unll;\
    rc-update add nginx default;

COPY nginx/ /etc/nginx/
COPY html/ /www/html/

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
