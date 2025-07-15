# FROM ubuntu:22.04

# RUN apt-get update && apt-get install -y \
#   curl unzip jq git libicu-dev

# RUN LATEST_TF=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r .current_version) && \
#   curl -fsSL "https://releases.hashicorp.com/terraform/${LATEST_TF}/terraform_${LATEST_TF}_linux_amd64.zip" -o terraform.zip && \
#   unzip terraform.zip && \
#   mv terraform /usr/local/bin/ && \
#   rm terraform.zip

# CMD ["terraform", "-version"]


FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
  curl \
  unzip \
  jq \
  git \
  libicu-dev \
  ca-certificates \
  gnupg \
  lsb-release \
  apt-transport-https \
  software-properties-common

# Install Docker (official method)
RUN mkdir -p /etc/apt/keyrings && \
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
  apt-get update && \
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install latest Terraform
RUN LATEST_TF=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r .current_version) && \
  curl -fsSL "https://releases.hashicorp.com/terraform/${LATEST_TF}/terraform_${LATEST_TF}_linux_amd64.zip" -o terraform.zip && \
  unzip terraform.zip && \
  mv terraform /usr/local/bin/ && \
  rm terraform.zip

# Default command (can be overridden)
CMD ["terraform", "-version"]
