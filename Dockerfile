# To run this image locally
# make docker_run
# You can connect to the running container using
# docker exec -t -i bot /bin/sh

FROM alpine:3.16 as base

FROM golang:1.19.2-alpine3.16 as builder

WORKDIR /codebase

# Full package list is here https://pkgs.alpinelinux.org/packages
# build-base = To install make
# upx = To shrink the binary
RUN apk add --no-cache build-base upx
COPY Makefile go.mod go.sum /codebase/
COPY src /codebase/src
RUN make build_prod

FROM base
WORKDIR /
ARG BINARY_NAME
ENV BINARY_PATH="/bin/${BINARY_NAME}"
COPY --from=builder /codebase/bin/* ${BINARY_PATH}
COPY website /website
RUN ls -l ${BINARY_PATH}
# Optional: Copy more stuff into final image here

CMD ["sh", "-c", "${BINARY_PATH}"]
