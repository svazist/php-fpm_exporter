FROM golang:1.11-alpine3.8 AS build
RUN apk add git
WORKDIR /go/src/app
COPY . .
RUN go get -d -v ./...
#RUN go install -v ./...
RUN env GOOS=linux CGO_ENABLED=0 GOARCH=amd64 go build -o ./php-fpm_exporter main.go

FROM alpine:3.8

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

COPY --from=build /go/src/app/php-fpm_exporter /

EXPOSE     9253
CMD [ "/php-fpm_exporter", "server" ]

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="php-fpm_exporter" \
      org.label-schema.description="A prometheus exporter for PHP-FPM. (modification by Svazist)" \
      org.label-schema.url="https://hipages.com.au/" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/svazist/php-fpm_exporter" \
      org.label-schema.vendor="hipages" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0" \
      org.label-schema.docker.cmd="docker run -it --rm -e PHP_FPM_SCRAPE_URI=\"tcp://127.0.0.1:9000/status\" hipages/php-fpm_exporter"
