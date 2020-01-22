#!/bin/sh
export DOCKER_CLI_EXPERIMENTAL=enabled
export IMG_DISABLE_EMBEDDED_RUNC=1

./config.sh --url $RUNNER_URL --token $RUNNER_TOKEN --name $RUNNER_NAME --work $RUNNER_WORK_DIR

./run.sh