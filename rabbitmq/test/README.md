# RabbitMQ Test Cluster

Test cluster is a set of scripts and configuration files that enable setting up cluster nodes on a
single computer easier and faster. Test cluster scripts are available for `Linux` and `Windows`
with using `bash` and `PowerShell` respectively.

Following is a tutorial on how to get going with test cluster. It assumes that you have `RabbitMQ`
installed on your system.

The folder structure for a cluster is rather straight forward and looks somewhat like this:

```{.plain}
test-cluster/nodes/
    primary/
        logs/             <- all log files
        mnesia/           <- runtime database
        .erlang.cookie
        enabled_plugins   <- list of enabled plugins
        rabbitmq.config   <- effectively after preparation
    secondary/
        ...
    witness/
        ...
```

Structure of the folders for `primary`, `secondary` and `witness` is almost identical.

## Windows

```{.bash}
. .\test-cluster\init.ps1
```

This will import following functions into your `PowerShell` sessions:

* `tc-start`
* `tc-stop`
* `tc-prepare`
* `tc-node`
* `tc-configure`

Prepare function sets ports for all three nodes in a cluster. Typically it needs to be executed
only once.  Node function allows to execute any `rabbitmq-server`, `rabbitmqctl`, etc. commands on
specific cluster nodes.  Configure function is there to configure some users and policies for a
cluster.

In order to successfully start a cluster it is typically enough to do the following:

```{.bash}
tc-prepare 5701 5702 5703
tc-node all "rabbitmq-server -detached"
tc-configure primary users
tc-configure primary policies
```

Which is exactly equivalent to a simple call to `tc-start` (parameters are optional here):

```{.bash}
tc-start 5701 5702 5703
```

This will prepare a cluster to run primary node on port `5701`, secondary node on port `5702` and
witness node - `5703`. This will also enable management plugins for each node on ports `15701`,
`15702` and `15703` respectively ([primary](http://localhost:15701),
[secondary](http://localhost:15702) and [witness](http://localhost:15703)). Then it will instruct
all nodes of a cluster to start. And lastly it will configure users (introduce `admin` user with
`admin` password and disable `guest` user) as well as configure policies (to make sure all queues
are mirrored across all nodes).

In order to check the status of a node of a running cluster it is enough to do the following:

```{.bash}
tc-node primary "rabbitmqctl cluster_status"
```

This should result in the following output:

```{.plain}
Cluster status of node 'rabbit-primary@host' ...
[{nodes,[{disc,['rabbit-primary@host']},
         {ram,['rabbit-witness@host','rabbit-secondary@host']}]},
 {running_nodes,['rabbit-witness@host','rabbit-secondary@host',
                 'rabbit-primary@host']},
 {cluster_name,<<"rabbit-primary@host.tst">>},
 {partitions,[]}]
```

After having cluster running for some time in order to shut it down correctly it is normally enough
to do the following:

```{.bash}
tc-node all "rabbitmqctl stop"
```

or following version which will do essentially the same plus it will also cleanup git repository:

```{.bash}
tc-stop
```

## Linux

On linux it seems to be impossible to set custom path to `.erlang.cookie` file. But that should not
be a problem since all nodes in a cluster will be using single machine level `.erlang.cookie` file.

First things first! We need to get access to all the functions available in this package. For that
it is necessary to source `init.sh` script.

```{.bash}
source test-cluster/init.sh
```

This will import following functions into your `bash` sessions:

* `tc-start`
* `tc-stop`
* `tc-prepare`
* `tc-node`
* `tc-configure`

Prepare function sets ports for all three nodes in a cluster. Typically it needs to be executed
only once.  Node function allows to execute any `rabbitmq-server`, `rabbitmqctl`, etc. commands on
specific cluster nodes.  Configure function is there to configure some users and policies for a
cluster.

In order to successfully start a cluster it is typically enough to do the following:

```{.bash}
tc-prepare 5701 5702 5703
tc-node all "rabbitmq-server -detached"
tc-configure primary users
tc-configure primary policies
```

Which is exactly equivalent to a simple call to `tc-start` (parameters are optional here):

```{.bash}
tc-start 5701 5702 5703
```

This will prepare a cluster to run primary node on port `5701`, secondary node on port `5702` and
witness node - `5703`. This will also enable management plugins for each node on ports `15701`,
`15702` and `15703` respectively ([primary](http://localhost:15701),
[secondary](http://localhost:15702) and [witness](http://localhost:15703)). Then it will instruct
all nodes of a cluster to start. And lastly it will configure users (introduce `admin` user with
`admin` password and disable `guest` user) as well as configure policies (to make sure all queues
are mirrored across all nodes).

In order to check the status of a node of a running cluster it is enough to do the following:

```{.bash}
tc-node primary "rabbitmqctl cluster_status"
```

This should result in the following output:

```{.plain}
Cluster status of node 'rabbit-primary@host' ...
[{nodes,[{disc,['rabbit-primary@host']},
         {ram,['rabbit-witness@host','rabbit-secondary@host']}]},
 {running_nodes,['rabbit-witness@host','rabbit-secondary@host',
                 'rabbit-primary@host']},
 {cluster_name,<<"rabbit-primary@host.tst">>},
 {partitions,[]}]
```

After having cluster running for some time in order to shut it down correctly it is normally enough
to do the following:

```{.bash}
tc-stop
```

This is equivalent to the following set of commands:

```{.bash}
tc-node all "rabbitmqctl stop"
```

If you are working from a local git repository it might come strange at first that cleaning folder
structure fails when following command is executed:

```{.bash}
git clean -d -f -x
```

In order to cleanup your folder structure, please fallback to the following command instead:

```{.bash}
sudo -E git clean -d -f -x
```

