# Service Group - MySQL

Service groups can have a MySQL instance deployed.


## Overview


## Connecting
MySQL databases deployed in service groups do not have public IP addresses, so
a connect must be made from a machine on the same network.


### Cluster Jump Box

This can be done by connecting from a cluster jump box, see how this can be
done [here][jump-box].


### Instance Connection Name

Acquire the instance connection name from the [SQL Instances][sql-instances]
page in the project for your environment.
The instane name will be the name of the service group you are working in with
a random suffix.
There is a column for the _Instance connection name_, copy this value for the
instance that you want to connect to.


### MySQL Proxy

On the jump box instance, run this command, replacing
`INSTANCE_CONNECTION_NAME` with the instance connection name you copied
earlier:
```shell
cloud-sql-proxy --private-ip INSTANCE_CONNECTION_NAME
```
This will open a local port to connect through to the MySQL instance.


### Datbase Credentials

Credentials for the database are generated and stored in Google Secrets 
manager.
These can be viewed [here][secret-manager] in the project for your
environment.
The secret for the `root` user credentials will be in a secret called:
`{SG_NAME}-cloudsql-root`, where `{SG_NAME}` is the name of the service
group you are working with.
Navigate to this secret and view the latest version to get the `root`
user credentials.


### `mysql` Client Connection

The `mysql` CLI client is installed on the cluster jump box and can be
used to make the connection via the CloudSQL proxy, provide the `root`
user password when prompted:

```shell
mysql -h 127.0.0.1 -u root -p
```

**WARNING: Please do not:**
- Provide any passwords in commands as this will get stored in shell
  history.
- Store any credentials on the jump box, for example in scripts.


<!-- Links -->
[jump-box]: /docs/cluster-jump-box.md
[sql-instances]: https://console.cloud.google.com/sql/instances
[secret-manager]: https://console.cloud.google.com/security/secret-manager

