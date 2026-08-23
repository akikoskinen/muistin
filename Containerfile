FROM docker.io/library/elixir:1.20-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      nodejs \
      npm \
      git \
      inotify-tools \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV=dev
ENV PORT=4000

EXPOSE 4000

CMD ["bash"]
