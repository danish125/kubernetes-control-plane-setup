FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
  curl unzip jq git libicu-dev

RUN LATEST_TF=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r .current_version) && \
  curl -fsSL "https://releases.hashicorp.com/terraform/${LATEST_TF}/terraform_${LATEST_TF}_linux_amd64.zip" -o terraform.zip && \
  unzip terraform.zip && \
  mv terraform /usr/local/bin/ && \
  rm terraform.zip

# CMD ["terraform", "-version"]
