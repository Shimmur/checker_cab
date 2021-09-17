FROM quay.io/shimmur/elixir:1.11.2-otp22.2.3

ARG HEXPM_KEY
ARG COVERALLS_REPO_TOKEN

WORKDIR /otp/app

RUN apk update && \
  apk add --no-cache git openssh-client bash build-base ffmpeg && \
  mix local.rebar --force && \
  mix local.hex --force

COPY . .

RUN mix hex.organization auth community --key $HEXPM_KEY && mix deps.get

RUN rm -rf _build

CMD ./ci/scripts/ci-container.sh
