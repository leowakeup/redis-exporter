#
# Alpine ARM64 release container
#
FROM arm64v8/alpine:3.6 as alpine-arm64

COPY --from=builder /redis_exporter /redis_exporter
COPY --from=builder /etc/ssl/certs /etc/ssl/certs

EXPOSE     9121
ENTRYPOINT [ "/redis_exporter" ]
