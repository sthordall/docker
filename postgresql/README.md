# PostgreSQL cluster image w/ replication

In order to start test PostgreSQL cluster with 3 nodes (synchronous replication
between single master and 2 replicas):

```bash
$ docker network create -d overlay pgnet
$ docker service create \
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
    kuznero/postgres:10.0-alpine-cluster
$ docker service create \
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
    kuznero/postgres:10.0-alpine-cluster
$ docker service create \
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
    kuznero/postgres:10.0-alpine-cluster
```

* `REPLICATE_FROM` is defined for slaves only; it indicates who is the primary node
* `ALLOW_REPLICATION_FROM` is defined for all nodes (default value is
  `10.0.0.1/16`); it indicates that any replication requests coming from an IP
  with this range is allowed, the rest is ignored
* `PG_MAX_WAL_SENDERS` maximum number of slaves (default: `8`)
* `PG_WAL_KEEP_SEGMENTS` see [runtime configuration for replication](http://www.postgresql.org/docs/9.6/static/runtime-config-replication.html) (default: `32`)
