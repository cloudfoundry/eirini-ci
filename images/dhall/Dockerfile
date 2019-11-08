FROM dhallhaskell/dhall as dhall

FROM ubuntu:bionic

COPY --from=dhall /bin/dhall /usr/local/bin/dhall
