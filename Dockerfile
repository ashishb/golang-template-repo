# To run this image locally
# make docker_run
# You can connect to the running container using
# docker exec -t -i bot /bin/sh

FROM alpine:3.11 as base

FROM golang:1.13.7-alpine3.11  as builder

WORKDIR /codebase

# To install make
RUN apk add --no-cache build-base
COPY Makefile go.mod go.sum /codebase/
COPY src /codebase/src
RUN ls -lR /codebase
RUN make build

FROM base
WORKDIR /
ARG BINARY_NAME
ENV BINARY_PATH="/bin/${BINARY_NAME}"
COPY --from=builder /codebase/bin/* ${BINARY_PATH}
COPY website /website
RUN ls -l ${BINARY_PATH}
# Optional: Copy more stuff into final image here

CMD ["sh", "-c", "${BINARY_PATH}"]
