#! /bin/bash

# please enter your config stuff

promoteCommand="touch /tmp/promotedb"
redirectCommand="sudo service postgresql-9.4 restart"

slave1IP="192.168.129.143"
slave1Port="5432"

slave2IP="192.168.129.202"
slave2Port="5432"

pcpport="9898"
pcpuser="postgres"
pcppass="postgres"

# let's find out what server is ahead (if any) and promote it

slave1LastLog=$(psql -U postgres -h $slave1IP -p $slave1Port -t -c "select pg_last_xlog_replay_location();")
slave2LastLog=$(psql -U postgres -h $slave2IP -p $slave2Port -t -c "select pg_last_xlog_replay_location();")

#echo $slave1LastLog
#echo $slave2LastLog

if [[ ! "$slave1LastLog" < "$slave2LastLog" ]]; then
    echo "one is ahead! (or the same)"
    promotedServerIP=$slave1IP
    redirectedServerIP=$slave2IP
    reattachID=2
else
    echo "one is behind"
    promotedServerIP=$slave2IP
    redirectedServerIP=$slave1IP
    reattachID=1
fi

ssh admra@$slave1IP  "$promoteCommand"

# now that we have a new master, let's point the other one to it

tmpfile=tmpfilerandomstufftomakesureimnotoverwritingyourfiles2JKHEGR7Q23

echo "standby_mode=on" > $tmpfile 
echo "trigger_file='/tmp/promotedb'" >> $tmpfile
echo "primary_conninfo='host=$promotedServerIP port=$slave1Port user=replicador application_name=postgresql$reattachID'" >> $tmpfile
echo "recovery_target_timeline='latest'" >> $tmpfile

scp $tmpfile postgres@$redirectedServerIP:/var/lib/pgsql/9.4/data/recovery.conf
ssh admra@$slave2IP "$redirectCommand"

# the backend stuff is done, now we need to reattach the redirected server to the user facing pgpool
pcp_attach_node 10 localhost $pcpport $pcpuser $pcppass $reattachID

rm $tmpfile
