FROM golang:1.10.3-alpine as gobuilder
ARG  GOAPP=oauth2_proxy
ENV  CGO_ENABLED=0 
ENV  GOOS=linux
RUN apk add -U --no-cache ca-certificates
COPY . /go/src/github.com/agilestacks/${GOAPP}/
WORKDIR /go/src/github.com/agilestacks/${GOAPP}
RUN go build -o /opt/bin/${GOAPP} -v ${GOAPP}

FROM scratch
ARG  GOAPP=oauth2_proxy
COPY --from=gobuilder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=gobuilder /opt/bin/${GOAPP} /oauth2_proxy
ENTRYPOINT ["/oauth2_proxy"]
