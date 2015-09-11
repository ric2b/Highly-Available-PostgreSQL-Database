# Slaves PostgreSQL servers

The Slave servers are set up identically to the Master except you need to add a **recovery.conf** file. Other than that you might want some slight differences on what connections you allow (which you change on the **pg_hba.conf** file) from each machine.

Refer to the [project wiki](wiki/) if you're a bit lost.

## What you probably need to change

Since we use pg_basebackup to start configuring the Slaves all you really need to do extra is add the **recovery.conf** file.
The other files are probably already correct but you may still want to customize **pg_hba.conf**

### recovery.conf
- location: PostgreSQL data folder

Just copy the file and change `primary_conninfo`'s IP and application_name.

### pg_hba.conf
- location: PostgreSQL data folder

You need to add rules for at least all the slaves and load balancers. Add whole subnets to make it simpler, if you can.
The file itself has quite a bit of documentation that you can read if confused, or you can also go to the [official documentation page](http://www.postgresql.org/docs/9.4/static/auth-pg-hba-conf.html)
