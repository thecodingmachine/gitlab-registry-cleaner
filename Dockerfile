FROM alpine:3.6

ENV KUBE_LATEST_VERSION="v1.10.0"

RUN apk add --update ca-certificates \
 && apk add --update curl \
 && apk add --update gettext \
 && apk add --update bash \
 && curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
 && chmod +x /usr/local/bin/kubectl \
 && rm /var/cache/apk/*

ADD delete_image.sh /delete_image.sh
