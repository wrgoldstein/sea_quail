FROM bitwalker/alpine-elixir-phoenix:latest as build

ARG SECRET_KEY_BASE
ARG HMAC_SECRET

# install build dependencies
RUN apk add --update git build-base nodejs yarn python

EXPOSE 5000
ENV PORT=5000 MIX_ENV=prod

# prepare build dir
RUN mkdir /app
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get
RUN mix deps.compile

# build assets
COPY assets assets
RUN cd assets && npm install && npm run deploy
RUN mix phx.digest

# build project
COPY priv priv
COPY lib lib
RUN mix compile

# build release
COPY rel rel
RUN mix release

# prepare release image
FROM alpine:3.9 AS app
RUN apk add --update bash openssl

RUN mkdir /app
WORKDIR /app

COPY --from=build /app/_build/prod/rel/sea_quail ./
# ADD assets/package.json assets/
RUN chown -R nobody: /app
USER nobody

ENV HOME=/app
CMD ["bin/sea_quail", "start"]
