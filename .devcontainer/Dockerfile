FROM python:3.12-slim-bullseye

RUN apt update && \
    apt install -y --no-install-recommends \
        awscli curl jq \
        # git needs ssh
        ssh \
        # install Node.js for CDK
        nodejs npm

# update latest pip
RUN pip install --upgrade pip

# update latest Node
RUN npm install -g n && \
    n stable

# install aws cli
RUN npm install -g aws-cdk
