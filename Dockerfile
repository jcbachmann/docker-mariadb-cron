# latest so CI can auto update the image properly
FROM mariadb:latest

RUN true \
    && apt update \
    && apt install -y \
        cron \
    && rm -rf /var/lib/apt \
    && true

COPY ./entrypoint.sh /

RUN chmod +x entrypoint.sh

ENTRYPOINT [ \
    "/entrypoint.sh", \
]

CMD [ \
    "/sbin/cron", \
    "-f",\
]
