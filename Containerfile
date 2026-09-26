# Base - Elixir with build tools
FROM docker.io/library/elixir:1.20-slim AS base

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      nodejs \
      npm \
      git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

# Development image - needed tools, but nothing else.
# Can be used by mounting the source code as a volume.
FROM base AS dev

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      inotify-tools \
    && rm -rf /var/lib/apt/lists/*

ENV MIX_ENV=dev
ENV PORT=4000

EXPOSE 4000

CMD ["bash"]

# Production build - compile and package into a release
FROM base AS prod-builder

COPY . .
ENV MIX_ENV=prod
RUN mix deps.get --only prod
RUN mix deps.compile
RUN mix compile
RUN mix assets.deploy
RUN mix release

# Production runtime image
FROM docker.io/library/elixir:1.20-slim AS prod

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      libsqlite3-0 \
      ca-certificates \
      adduser \
    && rm -rf /var/lib/apt/lists/*

RUN addgroup --system appuser && \
    adduser --system --ingroup appuser --no-create-home appuser

WORKDIR /app

COPY --from=prod-builder /app/_build/prod/rel/muistin /app/release

USER appuser

ENV MIX_ENV=prod
ENV PORT=4000
ENV PHX_SERVER=true
ENV DATABASE_PATH=/app/data/muistin.db

EXPOSE 4000

CMD ["/app/release/bin/muistin", "start"]
