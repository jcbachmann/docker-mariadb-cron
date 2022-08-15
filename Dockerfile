# latest so CI can auto update the image properly
FROM mariadb:latest

RUN true \
    && apt update \
    && apt install -y \
        cron \
    && rm -rf /var/lib/apt \
    && true

CMD [ \
    "/sbin/cron", \
    "-f",\
]
