# ----- Use Go base container -----
FROM golang:alpine

# copy sources
WORKDIR /build
COPY ./ ./

# install necessary tools
RUN apk add --no-cache git upx

# compile static & stripped binary
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o go

# compress binary
RUN upx ./go


# ----- create minimal final image -----
FROM scratch

# copy binary
COPY --from=0 /build/go /go

# default address and data dir
EXPOSE 8067
VOLUME /data

# entrypoint command
ENTRYPOINT ["/go"]
CMD ["-data", "/data"]
