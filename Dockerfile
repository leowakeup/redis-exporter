#
# build container
#
FROM golang:1.13-alpine as builder
WORKDIR /go/src/github.com/oliver006/redis_exporter/

ADD *.go /go/src/github.com/oliver006/redis_exporter/
ADD vendor /go/src/github.com/oliver006/redis_exporter/vendor

ARG GOARCH="arm64"
ARG SHA1="[no-sha]"
ARG TAG="[no-tag]"

RUN apk --no-cache add ca-certificates
RUN BUILD_DATE=$(date +%F-%T) && CGO_ENABLED=0 GOOS=linux GOARCH=$GOARCH go build -o /redis_exporter \
    -ldflags  "-s -w -extldflags \"-static\" -X main.BuildVersion=$TAG -X main.BuildCommitSha=$SHA1 -X main.BuildDate=$BUILD_DATE" .

RUN [ $GOARCH = "amd64" ]  && /redis_exporter -version || ls -la /redis_exporter


#
# Alpine ARM64 release container
#
FROM arm64v8/alpine:3.6 as alpine-arm64

COPY --from=builder /redis_exporter /redis_exporter
COPY --from=builder /etc/ssl/certs /etc/ssl/certs

EXPOSE     9121
ENTRYPOINT [ "/redis_exporter" ]