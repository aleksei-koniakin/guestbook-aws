FROM hashicorp/terraform:latest

RUN apk add --update --no-cache \
        docker \
        jq \
        packer \
        python3 \
        py3-pip \
    && pip3 install --upgrade pip \
    && pip3 install --no-cache-dir awscli \
    && rm -rf /var/cache/apk/*

