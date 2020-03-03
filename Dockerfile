# To run this image locally
# make docker_run
# You can connect to the running container using
# docker exec -t -i bot /bin/sh

FROM alpine:3.11 as base

FROM golang:1.13.7-alpine3.11  as builder

WORKDIR /codebase

COPY Makefile go.mod go.sum /codebase/
COPY src /codebase/src
# To install make
RUN apk add --no-cache build-base
RUN ls -lR /codebase
RUN make build

FROM base
WORKDIR /binary
COPY --from=builder /codebase/bin/* bin/
# Optional: Copy more stuff into final image here

CMD ["bin/BINARY_NAME", "args"]
