FROM alpine:latest

RUN set -x \
	apk update && \
	apk add --no-cache bash rsync curl supercronic shadow && \
	useradd -m app

ADD syncrepo_arch.sh /
ADD syncrepo_termux.sh /

COPY crontab .