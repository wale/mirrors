FROM alpine:latest

RUN set -x \
	apk update && \
	apk add --no-cache rsync curl supercronic shadow && \
	useradd -m app

ADD syncrepo.sh /

COPY crontab .