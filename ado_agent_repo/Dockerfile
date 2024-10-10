#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

FROM public.ecr.aws/ubuntu/ubuntu:22.04 AS tools
RUN apt update &&  apt upgrade -y

RUN apt-get install -y -qq --no-install-recommends \
    libicu70 \
    apt-transport-https \
    apt-utils \
    ca-certificates \
    curl \
    git \
    iputils-ping \
    jq \
    lsb-release \
    software-properties-common \
    wget \
    unzip \
    &&  apt-get clean

# Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64'.
ENV TARGETARCH=linux-x64

################################
# Install python
################################

RUN apt-get install -y python3-pip \
   && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* \
   && pip3 install --upgrade pip \
   && python3 -V \
   && pip --version

ENV DEBIAN_FRONTEND=noninteractive
RUN set -ex \
    && apt-get update \
    && apt-get install figlet jq tree xvfb libfontconfig wkhtmltopdf graphviz gawk golint -y -qq \
    &&  rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

################################
# Install AWS CLI
################################
# Install AWS CLI v2
# https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html
RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip \
    && unzip -q /tmp/awscliv2.zip -d /opt \
    && /opt/aws/install --update -i /usr/local/aws-cli -b /usr/local/bin \
    && rm /tmp/awscliv2.zip \
    && rm -rf /opt/aws \
    && aws --version
# AWS Tools
# https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html
RUN curl -sS -o /usr/local/bin/aws-iam-authenticator https://s3.us-west-2.amazonaws.com/amazon-eks/1.25.6/2023-01-30/bin/linux/amd64/aws-iam-authenticator \
    && curl -sS -o /usr/local/bin/kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.25.6/2023-01-30/bin/linux/amd64/kubectl \
    && curl -sS -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest \
    && curl -sS -L https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz | tar xz -C /usr/local/bin \
    && chmod +x /usr/local/bin/kubectl /usr/local/bin/aws-iam-authenticator /usr/local/bin/ecs-cli /usr/local/bin/eksctl
# OpenTofu
# Download the installer script:
RUN curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh \
    && chmod +x install-opentofu.sh \
    && ./install-opentofu.sh --install-method deb \
    && rm -f install-opentofu.sh


# Terragrunt
ARG TERRAGRUNT_VERSION=0.67.15
RUN set -ex \
     && wget https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 -q \
     && mv terragrunt_linux_amd64 /usr/local/bin/terragrunt \
     && chmod +x /usr/local/bin/terragrunt
# private packages
ARG PIP_EXTRA_INDEX_URL

# Python packages
ARG PYTHON_TERRAFORM_COMPLIANCE_VERSION=1.3.47
ARG PRE_COMMIT_VERSION=3.6.0


RUN set -ex \
    && pip3 install --no-cache-dir --upgrade "terraform-compliance==$PYTHON_TERRAFORM_COMPLIANCE_VERSION" \
    && pip3 install --no-cache-dir --upgrade "pre-commit==$PRE_COMMIT_VERSION" \
    && pip3 install --no-cache-dir --upgrade checkov

ENV PIP_EXTRA_INDEX_URL=${PIP_EXTRA_INDEX_URL}
RUN pip3 install iacpeerbot

WORKDIR /azp/

COPY ./start.sh ./
RUN chmod +x ./start.sh &&\
    useradd agent && mkdir -p /home/agent/.azure-devops \
    && chown agent ./ \
    && mkdir -p /home/agent/.terraform.d/plugin-cache  \
    && echo 'plugin_cache_dir   = "/home/agent/.terraform.d/plugin-cache"' > ~/.terraformrc \
    && echo 'plugin_cache_may_break_dependency_lock_file = true' > ~/.terraformrc \
    && echo 'plugin_cache_dir   = "/home/agent/.terraform.d/plugin-cache"' > ~/.tofurc \
    && echo 'plugin_cache_may_break_dependency_lock_file = true' > ~/.tofurc \
    && chown -R agent /home/agent/

USER agent
# Another option is to run the agent as root.
# ENV AGENT_ALLOW_RUNASROOT="true"
FROM tools AS runtime

ENTRYPOINT ["./start.sh"]

HEALTHCHECK --interval=1m --timeout=10s --start-period=5s --retries=3 \
  CMD pgrep -F /var/run/azp_agent.pid || exit 1