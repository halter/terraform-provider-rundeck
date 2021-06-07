#! /bin/bash

set -eou pipefail

default_tag="3.3.12"

# Local Administrator
# Username: admin
# Password: admin
# API token: 1d08bf61-f962-467f-8ba3-ab8a463b3467

if test $# -eq 0; then
  echo "please specify either 'start' or 'test'"
  exit 1
fi

case "$1" in
  "start")
    docker run --rm --init -d \
      --entrypoint /entrypoint.sh \
      -v $(pwd)/test/tokens.properties:/home/rundeck/etc/tokens.properties \
      -v $(pwd)/test/remco:/mnt/etc/remco \
      -v $(pwd)/test/entrypoint.sh:/entrypoint.sh \
      -p 4440:4440 \
      --name rundeck \
      rundeck/rundeck:${2:-$default_tag}

    echo "Waiting for login page..."
    timeout 300 bash -c 'while [[ "$(curl -s -o /dev/null -w "%{http_code}" '"http://localhost:4440/user/login"')" != "200" ]]; do sleep 5; done'
    echo "Rundeck running."
    ;;
  "test")
    TF_ACC=1 \
    RUNDECK_URL=http://localhost:4440 \
    RUNDECK_AUTH_TOKEN=1d08bf61-f962-467f-8ba3-ab8a463b3467 \
    go test -v -cover -count 1 ./rundeck/
    ;;
  "stop")
    docker stop rundeck
    ;;
  "update")
    docker pull rundeck/rundeck:${2:-$default_tag}
    ;;
  *)
    echo "unrecognized command"
    exit 1
    ;;
esac
