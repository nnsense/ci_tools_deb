# Set tools versions
ARG TERRAFORM_VERSION="0.13.6"
ARG DEBIAN_VERSION=buster-20201012-slim

FROM debian:${DEBIAN_VERSION}
LABEL maintainer="nnsense"
ARG TERRAFORM_VERSION
RUN apt-get update && \
apt-get install --no-install-recommends -y && \
curl=7.64.0-4+deb10u1 \
ca-certificates=20190110 \
unzip=6.0-23+deb10u1 \
gnupg=2.2.12-1+deb10u1 && \
yum clean all && rm -rf /var/cache/yum

# Install helm
RUN curl "https://get.helm.sh/helm-v3.5.2-linux-amd64.tar.gz" -o helm.tar.gz && tar -zxvf helm.tar.gz
RUN mv linux-amd64/helm /usr/local/bin/helm
RUN rm -fr helm.tar.gz linux-amd64/

# Install terraform
RUN curl "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o "terraform.zip"
RUN unzip -j terraform.zip
RUN cp terraform /usr/local/bin/terraform
RUN rm -f terraform.zip

# Install kubectl
RUN STABLE_REL=$(curl -L -s https://dl.k8s.io/release/stable.txt) && export STABLE_REL
RUN curl -LO "https://dl.k8s.io/release/${STABLE_REL}/bin/linux/amd64/kubectl"
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install aws cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install
RUN rm -fr ./aws

WORKDIR /workspace
RUN groupadd --gid 1001 user \
  && useradd --gid user --create-home --uid 1001 user \
  && chown user:user /workspace
USER user

CMD ["bash"]
