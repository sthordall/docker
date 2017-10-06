#!/usr/bin/env bash

if [[ "$#" -ne 1 ]]; then
  echo "Expected argument is missing: start|stop."
  exit 1
fi

action=$1

if [ ! "$action" == "start" ]; then
  if [ ! "$action" == "stop" ]; then
    echo "Expected argument is missing: start|stop."
    exit 1
  fi
fi

if [ "$action" == "stop" ]; then
  docker service rm postgres-1
  docker service rm postgres-2
  docker service rm postgres-3
  docker network rm pgnet
  docker volume rm -f pg1
  docker volume rm -f pg2
  docker volume rm -f pg3
fi

if [ "$action" == "start" ]; then
  docker network create -d overlay pgnet
  docker build -t postgres-replication:dev .
  docker service create \
    --name postgres-1 \
    --detach \
    --network pgnet \
    -e POSTGRES_USER='postgres' \
    -e POSTGRES_PASSWORD='admin' \
    -e PG_ACTIVE_SYNC_NUM='1' \
    -e PG_SERVER_NAME='pg1' \
    -e PG_SYNC_SERVERS='pg2, pg3' \
    -e ALLOW_REPLICATION_FROM='10.0.0.1/16' \
    -e PGDATA='/var/lib/postgresql/data/pgdata' \
    --mount type=volume,source=pg1,target=/var/lib/postgresql/data/pgdata \
    -p 5432:5432 \
    postgres-replication:dev
  docker service create \
    --name postgres-2 \
    --detach \
    --network pgnet \
    -e POSTGRES_USER='postgres' \
    -e POSTGRES_PASSWORD='admin' \
    -e REPLICATE_FROM='postgres-1' \
    -e PG_SERVER_NAME='pg2' \
    -e ALLOW_REPLICATION_FROM='10.0.0.1/16' \
    -e PGDATA='/var/lib/postgresql/data/pgdata' \
    --mount type=volume,source=pg2,target=/var/lib/postgresql/data/pgdata \
    postgres-replication:dev
  docker service create \
    --name postgres-3 \
    --detach \
    --network pgnet \
    -e POSTGRES_USER='postgres' \
    -e POSTGRES_PASSWORD='admin' \
    -e REPLICATE_FROM='postgres-1' \
    -e PG_SERVER_NAME='pg3' \
    -e ALLOW_REPLICATION_FROM='10.0.0.1/16' \
    -e PGDATA='/var/lib/postgresql/data/pgdata' \
    --mount type=volume,source=pg3,target=/var/lib/postgresql/data/pgdata \
    postgres-replication:dev
fi
