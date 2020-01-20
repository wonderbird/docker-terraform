FROM hashicorp/terraform:light

LABEL maintainer="Stefan.Boos@gmx.de"

#####
# The python installation has been adopted from
# https://github.com/Docker-Hub-frolvlad/docker-alpine-python3/blob/master/Dockerfile

# The aws cli installation has been adopted from
# https://docs.aws.amazon.com/de_de/cli/latest/userguide/install-linux-al2017.html
# Note: The path is set in entrypoint.sh

# The azure cli installation has been adopted primarily from
# https://github.com/Azure/azure-cli/blob/dev/Dockerfile
# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest
#
# If building the azure-cli fails, then check whether the Dockerfile on github now requires
# a different JP_VERSION
# https://github.com/Azure/azure-cli/blob/dev/Dockerfile
ARG JP_VERSION="0.1.3"

# This hack is widely applied to avoid python printing issues in docker containers.
# See: https://github.com/Docker-Hub-frolvlad/docker-alpine-python3/pull/13
ENV PYTHONUNBUFFERED=1

RUN echo "**** install Python ****" && \
    apk add --no-cache python3 && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    \
    echo "**** install pip ****" && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache --upgrade pip setuptools wheel && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    \
    echo "**** install aws cli ***" && \
    apk add --no-cache bash && \
    pip3 install --no-cache --upgrade --user awscli && \
    echo "export PATH=/root/.local/bin:$PATH" > /root/.bashrc && \
    \
    echo "**** install azure cli ****" && \
    apk add --no-cache python3-dev && \
    apk add --no-cache bash openssh ca-certificates jq curl openssl git zip && \
    apk add --no-cache --virtual .build-deps gcc make openssl-dev libffi-dev musl-dev linux-headers && \
    apk add --no-cache libintl icu-libs libc6-compat && \
    update-ca-certificates && \
    git clone https://github.com/Azure/azure-cli.git /azure-cli


RUN curl -L https://github.com/jmespath/jp/releases/download/${JP_VERSION}/jp-linux-amd64 -o /usr/local/bin/jp \
 && chmod +x /usr/local/bin/jp \
 && pip install --no-cache-dir --upgrade jmespath-terminal

WORKDIR /azure-cli

RUN ./scripts/install_full.sh \
    && cat /azure-cli/az.completion >> /root/.bashrc \
    && runDeps="$( \
      scanelf --needed --nobanner --recursive /usr/local \
        | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
        | sort -u \
        | xargs -r apk info --installed \
        | sort -u \
      )" \
    && apk add --virtual .rundeps $runDeps

WORKDIR /
RUN rm -rf /azure-cli && \
    rm -rf /root/.cache

#### End of azure-cli installation specifics

#### Install helm
# https://helm.sh/docs/intro/install/
RUN echo "**** install azure cli ****" \
    && curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
    && chmod 700 get_helm.sh \
    && ./get_helm.sh \
    && rm ./get_helm.sh \
    && helm repo add stable https://kubernetes-charts.storage.googleapis.com/
#### End of helm installation

# docker-entrypoint.sh will execute the bash instead of terraform
COPY docker-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR /root

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/bin/bash"]