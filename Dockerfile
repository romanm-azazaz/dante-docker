FROM debian:stable as builder

ARG DANTE_VERSION=1.4.3
ARG PATH_TO_BUILD_DANTE=/etc/dante 

RUN apt-get update \
 && apt-get install -y  \
                    build-essential \ 
                    wget \ 
 && rm -rf /var/lib/apt/lists/*

RUN wget https://www.inet.no/dante/files/dante-${DANTE_VERSION}.tar.gz

RUN tar -zxvf dante-${DANTE_VERSION}.tar.gz

WORKDIR dante-${DANTE_VERSION}

RUN ./configure --prefix=${PATH_TO_BUILD_DANTE} \
 && make \
 && make install

FROM debian:stable-slim

COPY --from=builder /etc/dante /app
COPY sockd.conf /app/

WORKDIR /app/sbin
EXPOSE 1080
ENTRYPOINT [ "./sockd", "-f", "/app/sockd.conf", "-p", "/tmp/sockd.pid", "-N", "5"]