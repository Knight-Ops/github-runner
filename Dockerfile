FROM ubuntu:18.04
RUN apt-get update && \
    apt-get install --no-install-recommends curl ca-certificates git build-essential apt-transport-https \
    gnupg-agent software-properties-common uidmap libseccomp-dev golang go-bindata pkg-config runc liblttng-ust0 \
    libcurl4 libssl1.0.0 libkrb5-3 zlib1g libicu60 -y && \
    rm -rf /var/lib/apt/lists/*

ARG TARGETARCH 
ARG RUNNER_VERSION="2.164.0" 

# Install img for building docker images without DinD
RUN go get -d github.com/genuinetools/img
WORKDIR /root/go/src/github.com/genuinetools/img
RUN make
RUN mv /root/go/src/github.com/genuinetools/img/img /usr/local/bin/img

# Make our /run/runc for building and give everyone access
RUN mkdir /run/runc
RUN chmod 777 /run/runc

# Add a user so that the github runner is happy
RUN useradd -ms /bin/bash runner -G sudo
WORKDIR /home/runner

# Get the pre-built github runner binaries and install dependencies
RUN mkdir actions-runner && cd actions-runner
RUN if [ "${TARGETARCH}" = "amd64" ] ; then curl -OL https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz; else curl -OL https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${TARGETARCH}-${RUNNER_VERSION}.tar.gz; fi
RUN if [ "${TARGETARCH}" = "amd64" ] ; then tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz; else tar xzf ./actions-runner-linux-${TARGETARCH}-${RUNNER_VERSION}.tar.gz; fi

# Get kubectl so we can deploy our images
RUN if [ "${TARGETARCH}" = "amd64"] ; then curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl; else curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/arm64/kubectl ; fi
RUN chmod a+x kubectl && mv kubectl /usr/local/bin/kubectl

# Give our user ownership of their own directory
RUN chown -R runner:runner /home/runner
# Needed for img
ENV USER=runner
USER runner

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN rustup toolchain install nightly
ENV PATH=/home/runner/.cargo/bin:$PATH

COPY ./entrypoint.sh entrypoint.sh

ENTRYPOINT [ "./entrypoint.sh" ]