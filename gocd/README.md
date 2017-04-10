# Setting up GoCD in Docker Swarm Mode

Choose one node that will run `gocd-server` and create following folders:

```
/data/godata/addons
/data/godata/artifacts
/data/godata/config
/data/godata/db
/data/godata/logs
/data/godata/plugins
```

Label this node as following (choose one inspecting the output of `docker node ls`):

```bash
docker node update --label-add server=on <SERVER_NODE_ID>
```

Create go-server service

```bash
docker service create \
  --name go-server \
  --network ci \
  --replicas 1 \
  -p 8000:8153 \
  --constraint node.labels.server==on \
  --mount type=bind,source=/data/godata/addons,target=/godata/addons,readonly=false \
  --mount type=bind,source=/data/godata/artifacts,target=/godata/artifacts,readonly=false \
  --mount type=bind,source=/data/godata/config,target=/godata/config,readonly=false \
  --mount type=bind,source=/data/godata/db,target=/godata/db,readonly=false \
  --mount type=bind,source=/data/godata/logs,target=/godata/logs,readonly=false \
  --mount type=bind,source=/data/godata/plugins,target=/godata/plugins,readonly=false \
  gocd/gocd-server:v17.3.0
```

> You may want to choose `kuznero/gocd-server-65011:latest` auto built version
> that is using `${GID}=65011` and `${UID}=65011` instead of `1000` if it happen
> to collide with users/groups on your docker host.

Create go-agent service

```bash
docker service create \
  --name go-agent \
  --network ci \
  --replicas 5 \
  --constraint node.labels.server!=on \
  -e GO_SERVER=go-server \
  --mount type=bind,source=/usr/bin/docker,target=/usr/bin/docker \
  --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
  --mount type=bind,source=/usr/lib64/libltdl.so.7,target=/usr/lib/libltdl.so.7 \
  gocd/gocd-agent-ubuntu-16.04:v17.3.0
```

> Mounting docker with some of its dependent libraries might not work
> specifically in case of your OS/Docker version combination.
