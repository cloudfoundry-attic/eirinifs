ARG baseimage=cloudfoundry/cflinuxfs3:0.177.0
FROM golang:1.13 as builder
WORKDIR /eirinifs/
COPY . .
RUN CGO_ENABLED=0 go build -mod=vendor -a -installsuffix cgo -o launch ./launchcmd
RUN CGO_ENABLED=0 go build -mod=vendor -a -installsuffix cgo -o launcher ./buildpackapplifecycle/launcher

FROM ${baseimage}

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64
RUN chmod +x /usr/local/bin/dumb-init

COPY --from=builder /eirinifs/launcher /lifecycle/launcher
COPY --from=builder /eirinifs/launch /lifecycle/launch
