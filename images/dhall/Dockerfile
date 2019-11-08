FROM dhallhaskell/dhall as dhall

FROM ubuntu:bionic

COPY --from=dhall /bin/dhall /usr/local/bin/dhall

RUN apt-get update && apt-get install -y ca-certificates
