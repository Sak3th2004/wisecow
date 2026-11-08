FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        cowsay \
        fortune-mod \
        fortunes-min \
        netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*


ENV PATH="/usr/games:${PATH}"

WORKDIR /app
COPY wisecow.sh .
RUN chmod +x wisecow.sh

EXPOSE 4499
CMD ["./wisecow.sh"]