# The Master PostgreSQL server

The difference between the master and the slaves is pretty much only the **recovery.conf** file. It can't exist on the master, or it will start in stanby mode. Other than that you might want some slight differences on what connections you allow (which you change on the **pg_hba.conf** file) from each machine.

Refer to the [project wiki](wiki/) if you're a bit lost.

## What you probably need to change

### pg_hba.conf
- location: PostgreSQL data folder

You need to add rules for at least all the slaves and load balancers. Add whole subnets to make it simpler, if you can.
The file itself has quite a bit of documentation that you can read if confused, or you can also go to the [official documentation page](http://www.postgresql.org/docs/9.4/static/auth-pg-hba-conf.html)

### postgresql.conf
- location: PostgreSQL data folder

change `max_wal_senders = 4` if you need more than 4 Slave servers.

There are also some settings like timezones that you may want to change. These are changed on installation so I really don't know what the default values should be for you, maybe run a diff between the file I provide and the one you get after initiating a database.
