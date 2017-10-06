#!/bin/bash

if [ "x$REPLICATE_FROM" == "x" ]; then # master node

if [ ! "x$ALLOW_REPLICATION_FROM" == "x" ]; then
  IFS=',' read -r -a replicas <<< "$ALLOW_REPLICATION_FROM"
  echo "Configuring access to replicas:"
  for replica in "${replicas[@]}"; do
    echo "host    replication     all             $replica                trust" >> ${PGDATA}/pg_hba.conf
    echo "  * $replica"
  done
fi

cat >> ${PGDATA}/postgresql.conf <<EOF
max_connections = 100
shared_buffers = 128MB
wal_level = hot_standby
max_wal_senders = $PG_MAX_WAL_SENDERS
wal_keep_segments = $PG_WAL_KEEP_SEGMENTS
synchronous_standby_names = 'all'
synchronous_commit = on
EOF

else # replica node

if [ ! "x$ALLOW_REPLICATION_FROM" == "x" ]; then
  IFS=',' read -r -a replicas <<< "$ALLOW_REPLICATION_FROM"
  echo "Configuring access to replicas:"
  for replica in "${replicas[@]}"; do
    echo "host    replication     all             $replica                trust" >> ${PGDATA}/pg_hba.conf
    echo "  * $replica"
  done
fi

cat >> ${PGDATA}/postgresql.conf <<EOF
max_connections = 300
shared_buffers = 425MB
effective_cache_size = 850MB
synchronous_standby_names = '*'
synchronous_commit = on
hot_standby = on
wal_level = hot_standby
max_wal_senders = $PG_MAX_WAL_SENDERS
wal_keep_segments = $PG_WAL_KEEP_SEGMENTS
EOF

fi
