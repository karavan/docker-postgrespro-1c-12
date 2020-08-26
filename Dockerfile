FROM debian:buster-slim

ENV DEBIAN_FRONTEND noninteractive

RUN groupadd postgres --gid=999 \
  && useradd --gid postgres --uid=999 postgres

ENV GOSU_VERSION 1.7
RUN apt-key add - << END-OF-KEY
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1

mQENBFWdEjABCAC6QeLt0UJUQlDI2Z+R/y1OyOMU+5Te176I0+/Xpc2v5NsucW2M
kLTdOif0iW+q5h1djL+Pc5yu1fojZCvcihhbURnWECF52BmRnOC9jI0eTHq3fcPZ
IE3gqMJSn5sx2kJZ7n8XE0RbQ/hr51BLI+lzeqR3JAKBIqpVDKRrdP9Y1xVR/7Ne
q4FNR+osm6W4sM9G+TA/YADrWX3/TPXA4AN+2uNCNY0wK7em8V0oSZJVpEzvu5EP
djC6GX08XSvhPNo52o3u3tpFWH7ICw2BEYe672bJTjmi8wFgPW04pw49Jpvw4i1R
RhkpQqQ/b9bSveoNpvN32ElAJSaize76+q/TABEBAAG0KlJvYm90IChTaWduaW5n
IHJlcG9zKSA8ZGJhQHBvc3RncmVzcHJvLnJ1PokBOAQTAQIAIgUCVZ0SMAIbAwYL
CQgHAwIGFQgCCQoLBBYCAwECHgECF4AACgkQf5rlpi0t8LQpKQgAuJkOKNdnCSCt
GbNTwAbk414UPYa2B1M1DD6MfcSd6NnJNBVtRoaSWWISQB6gP+/w1jmD8XZbj/oH
5HAHjOyh9Lb3z1xeMIQnBnfGtcqmU5QrF55Yi0H9G0s+fn9oodfNXqAa/zARpBw6
q3LRSBCjT50/XA5G3AzUr7fIDb68FmEOCQukzs0uWBr5fkrRC21b1DcuhzbBay8X
pnlpB+Ma1PTIFgRdRl/KwYTzO80TWFMCeYfXQRh8StuQxRcVCqnv4F6seHqmbL7A
vOZ7GMymsz/IRHGVk4eVC6/94Y3vkV/0eQ+Yom+NtAFnep6G4OhxIeviZ697eFYF
+j4YsyDD+g==
=Q7MS
-----END PGP PUBLIC KEY BLOCK-----
END-OF-KEY 
REPO=http://repo.postgrespro.ru/pg1c-12
PRODUCT_NAME="PostgreSQL for 1C 12"
. /etc/os-release
top=$REPO/$ID
distr=$VERSION_CODENAME
listname=$(basename $REPO)
echo "# Repositiory for '$PRODUCT_NAME'" > "/etc/apt/sources.list.d/$listname.list"
echo "deb $top $distr main" >> "/etc/apt/sources.list.d/$listname.list"
apt-get -qq update \
  && apt-get -qq install --yes --no-install-recommends ca-certificates wget locales pigz postgrespro-1c-12 postgrespro-1c-12-contrib \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && wget --quiet -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true

RUN localedef --inputfile ru_RU --force --charmap UTF-8 --alias-file /usr/share/locale/locale.alias ru_RU.UTF-8
ENV LANG ru_RU.utf8

ENV SERVER_VERSION 1c-12
ENV PATH /opt/pgpro/$SERVER_VERSION/bin:$PATH
ENV PGDATA /data

RUN apt-get update -y \
    && apt-get install -y wget gnupg2 || apt-get install -y gnupg \
    && wget -O - http://repo.postgrespro.ru/keys/GPG-KEY-POSTGRESPRO | apt-key add - \
    && echo deb http://repo.postgrespro.ru/1c-archive/pg1c-11.1/ubuntu/ bionic main > /etc/apt/sources.list.d/postgrespro-1c.list \
    && apt-get update -y \
    && apt-get install -y postgrespro-1c-11-server postgrespro-1c-11-contrib \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir --parent /var/run/postgresql "$PGDATA" /docker-entrypoint-initdb.d \
  && chown --recursive postgres:postgres /var/run/postgresql "$PGDATA" \
  && chmod g+s /var/run/postgresql

COPY container/docker-entrypoint.sh /
COPY container/postgresql.conf.sh /docker-entrypoint-initdb.d

ENTRYPOINT ["/docker-entrypoint.sh"]

VOLUME $PGDATA

EXPOSE 5432

CMD ["postgres"]
