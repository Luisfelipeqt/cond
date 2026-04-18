# Find eligible builder and runner images on Docker Hub. We use global seach to
# avoid cross-platform issues.
#
#   https://hub.docker.com/r/hexpm/elixir/tags?page=1&name=1.19.5-erlang-28-debian-trixie-slim
#   https://hub.docker.com/_/debian?tab=tags&page=1&name=trixie-slim
#
# This file is based on these images:
#
#   - https://hub.docker.com/r/hexpm/elixir/tags - for the build image
#   - https://hub.docker.com/_/debian?tab=tags&page=1&name=trixie-20250428-slim - for the release image
#   - https://pkgs.org/ - resource for finding needed packages

ARG ELIXIR_VERSION=1.19.5
ARG OTP_VERSION=28.4.2
ARG UBUNTU_VERSION=noble-20260410

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-ubuntu-${UBUNTU_VERSION}"
ARG RUNNER_IMAGE="ubuntu:${UBUNTU_VERSION}"

FROM ${BUILDER_IMAGE} as builder

# install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv

COPY lib lib

# Compile the release first so phoenix-colocated hooks are generated in _build/prod/
RUN mix compile

COPY assets assets

# compile assets (needs _build/prod/phoenix-colocated generated above)
RUN mix assets.deploy

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel rel
RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}

RUN apt-get update -y && \
  apt-get install -y libstdc++6 openssl libncurses6 locales ca-certificates \
    pandoc python3-weasyprint \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen 2>/dev/null || true

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

# set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/app ./

RUN chmod +x /app/bin/migrate /app/bin/server

USER nobody

# If using an environment that doesn't automatically reap zombie processes, it is
# advised to add an init process such as tini via `apt-get install`
# to avoid this, we can set the STOPSIGNAL to SIGTERM to allow the process to exit cleanly
# CMD ["/app/bin/server"]

CMD ["/app/bin/server"]
