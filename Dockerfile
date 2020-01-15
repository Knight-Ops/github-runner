FROM ubuntu:18.04
RUN apt-get update && apt-get upgrade -y && apt-get install curl -y
ARG TARGETARCH

RUN useradd -ms /bin/bash runner -G sudo
WORKDIR /home/runner

ENV RUNNER_VERSION 2.163.1

RUN mkdir actions-runner && cd actions-runner
RUN if [ "${TARGETARCH}" = "amd64" ] ; then curl -O https://githubassets.azureedge.net/runners/${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz; else curl -O https://githubassets.azureedge.net/runners/${RUNNER_VERSION}/actions-runner-linux-${TARGETARCH}-${RUNNER_VERSION}.tar.gz; fi
RUN if [ "${TARGETARCH}" = "amd64" ] ; then tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz; else tar xzf ./actions-runner-linux-${TARGETARCH}-${RUNNER_VERSION}.tar.gz; fi
RUN ./bin/installdependencies.sh

RUN chown -R runner:runner /home/runner
USER runner

COPY ./entrypoint.sh entrypoint.sh

ENTRYPOINT [ "./entrypoint.sh" ]