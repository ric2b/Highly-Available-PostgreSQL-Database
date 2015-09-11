# PgPool II load balancers

The configuration files are pretty much the same for both servers except for the watchdog feature related ones, which must have each other's IP addresses.

If you feel a bit lost, check the [project wiki](../../../wiki)

## What you need to change

All these files should be on `/etc/pgpool-II/`

### failover.sh

The section until the `warnMe` function has the variables that you might want to change (and the function itself if you want to setup a warning system for you)

You also need to enable passwordless login from the PgPool machine to all the PostgreSQL machines (on both **sudoUser** and **postgresUser**)

### pcp.conf

Change to your pcp user and md5'd password

### pgpool.conf

Change the **backend connection settings**, possibly adding a few more servers if needed.

You may want to personalise the `white_function_list` or `black_function_list`. **One of them must be empty**.

Check if you need to change these:
- `sr_check_user`
- `sr_check_password` probably need to be changed as well
- `health_check_user`
- `health_check_password`

If you want to change the `health_check_period` to make the system failover faster or slower you should make sure that `health_check_timeout` remains a smaller value.

On the watchdog section, `wd_hostname` should be the machines own IP and `heartbeat_destination0` and `other_pgpool_hostname0` should be the other PgPool server.

The virtual IP section also has some fields that might need changing:
- `delegate_IP`
- `if_up_cmd`
- `if_down_cmd`

### pool_hba.conf

Like on the PostgreSQL machines, configure it to give access to the machines that will connect to PgPool.

### pool_passwd

Set the username and md5'd password that PgPool will use to access the PostgreSQL machines (if needed)
