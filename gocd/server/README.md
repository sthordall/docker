# Setting up GoCD in Docker Swarm Mode

### Establish overlay network

```bash
docker network create -d overlay ci
```

### Start GoCD Server

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

Here is how to create `go-server` service:

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
  gocd/gocd-server:v17.4.0
```

> You may want to choose `kuznero/gocd-server-65011:latest` auto built version
> that is using `${GID}=65011` and `${UID}=65011` instead of `1000` if it happen
> to collide with users/groups on your docker host.

### Start GoCD Agents

It will be assumed that `go-agent` service should use docker facilities where it
is hosted itself. For that it is required to share (i.e. mount) docker client
and its libraries into `go-agent` containers docker client can be used as if
`go-agent` has docker infrastructure installed in it natively.

And this is how to create `go-agent` service:

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
  gocd/gocd-agent-ubuntu-16.04:v17.4.0
```

> Mounting docker with some of its dependent libraries might not work
> specifically in case of your OS/Docker version combination.

> There are different versions of `gocd-agent-*` available, but `ubuntu` flavor
> was chosen specifically because mounted docker client is most likely to be
> compatible with it.

Do not forget that in order for the trick of re-using outer docker client to
work there should be a few thinkgs in place:

1. Docker engine where `go-agent` is going to be running should be started with
   the following option: `-H unix:///var/run/docker.sock`
2. `/var/run/docker.sock` file should have appropriate permissions, thus please
   ensure: `chmod 0666 /var/run/docker.sock`
