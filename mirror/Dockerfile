FROM ubuntu:latest

RUN DEBIAN_FRONTEND=noninteractive \
	apt update && \
	apt -y install rsync curl && \
	rm -rf /var/lib/apt/lists/*

ADD syncrepo.sh /

CMD ["/syncrepo.sh"]