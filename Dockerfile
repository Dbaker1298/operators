FROM docker.io/alpine:3.22.1

LABEL maintainer="David Baker <admin@still-learning.tech>"
LABEL version="1.0"
LABEL description="Docker image for operators with kubectl and custom script"

RUN set -eux; \
    apk add --no-cache bash jq curl tree; \
    KUBECTL_VERSION="v1.32.1"; \
    curl -fsSLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"; \
    curl -fsSLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256"; \
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum -c -; \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl; \
    rm kubectl kubectl.sha256

COPY shell/v3/main.sh /usr/local/bin/grafzahl

RUN chmod +x /usr/local/bin/grafzahl

ENTRYPOINT ["/usr/local/bin/grafzahl"]