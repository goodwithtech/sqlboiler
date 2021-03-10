# builder
FROM golang:1.13-alpine AS builder

RUN apk add git build-base

WORKDIR /go/src/github.com/volatiletech/sqlboiler

COPY . .
RUN go get -v -t ./...
RUN go build -trimpath -ldflags "-w -s" . && \
    go build -trimpath -ldflags "-w -s" ./drivers/sqlboiler-psql && \
    go build -trimpath -ldflags "-w -s" ./drivers/sqlboiler-mysql && \
    go build -trimpath -ldflags "-w -s" ./drivers/sqlboiler-mssql


# sqlboiler (contains all drivers)
FROM alpine:3.13 AS sqlboiler

WORKDIR /sqlboiler

COPY --from=builder /go/src/github.com/volatiletech/sqlboiler/sqlboiler-mssql \
                    /go/src/github.com/volatiletech/sqlboiler/sqlboiler-mysql \
                    /go/src/github.com/volatiletech/sqlboiler/sqlboiler-psql \
                    /usr/local/bin/
ENTRYPOINT [ "sqlboiler" ]