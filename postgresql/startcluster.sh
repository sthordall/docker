docker build -t postgres-replication .
docker stack deploy -c cluster.yaml pg
