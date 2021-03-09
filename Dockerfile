# Set tools versions
ARG TERRAFORM_VERSION="0.13.6"
ARG DEBIAN_VERSION=stretch-slim

FROM debian:${DEBIAN_VERSION}
LABEL maintainer="nnsense"
ARG TERRAFORM_VERSION
RUN apt-get update && \
apt-get install --no-install-recommends -y \
git=1:2.11.0-3+deb9u7 \
curl=7.52.1-5+deb9u13 \
ca-certificates=20200601~deb9u1 \
unzip=6.0-21+deb9u2 \
gnupg=2.1.18-8~deb9u4 && \
apt-get clean && rm -rf /var/cache/apt/archives

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
