FROM dhallhaskell/dhall-json as dhall-json

FROM ubuntu:bionic

COPY --from=dhall-json /bin/dhall-to-json /usr/local/bin/dhall-to-json

RUN apt-get update && apt-get install -y ca-certificates
