FROM debian:buster-slim

ENV DEBIAN_FRONTEND noninteractive
ENV REPO "http://repo.postgrespro.ru/pg1c-12/debian"
ENV PRODUCT_NAME "PostgreSQL for 1C 12"
ENV SERVER_VERSION 1c-12
ENV PATH /opt/pgpro/$SERVER_VERSION/bin:$PATH
ENV PGDATA /data
ENV DISTR buster
ENV GOSU_VERSION 1.12

RUN groupadd postgres --gid=999 && \
useradd --gid postgres --uid=999 postgres && \
apt-get -qq update && \
apt-get -qq install --yes --no-install-recommends apt-utils ca-certificates curl locales pigz gnupg procps && \
curl -s http://repo.postgrespro.ru/keys/GPG-KEY-POSTGRESPRO | apt-key add - && \
echo "# Repositiory for '$PRODUCT_NAME'" > "/etc/apt/sources.list.d/postgrespro.list" && \
echo "deb $REPO $DISTR main" >> "/etc/apt/sources.list.d/postgrespro.list" && \
curl -Lso /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" && \
chmod +x /usr/local/bin/gosu && \
gosu nobody true && \
apt-get -qq update && \
apt-get -qq install --yes --no-install-recommends postgrespro-1c-12 postgrespro-1c-12-contrib && \
apt-get clean && \
rm -rf /var/lib/apt/lists/* && \
localedef --inputfile ru_RU --force --charmap UTF-8 --alias-file /usr/share/locale/locale.alias ru_RU.UTF-8

ENV LANG ru_RU.utf8

RUN mkdir --parent /var/run/postgresql "$PGDATA" /docker-entrypoint-initdb.d \
  && chown --recursive postgres:postgres /var/run/postgresql "$PGDATA" \
  && chmod g+s /var/run/postgresql

COPY container/docker-entrypoint.sh /
COPY container/postgresql.conf.sh /docker-entrypoint-initdb.d

ENTRYPOINT ["/docker-entrypoint.sh"]

VOLUME $PGDATA

EXPOSE 5432

CMD ["postgres"]
