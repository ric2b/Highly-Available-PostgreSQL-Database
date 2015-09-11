#! /bin/bash

# please enter your config stuff

nodeIDs=( 0 1 2 3 )
nodeIPs=(
            192.168.129.123
            192.168.129.143
            192.168.129.202
            192.168.129.245
        )

nodePorts=( 5432 5432 5432 5432 )

sudoUser="admra"
postgresUser="postgres"

pcpport="9898"
pcpuser="postgres"
pcppass="postgres"

dataFolder="/var/lib/pgsql/9.4/data/"

### If you want to setup a warning just enter it in the function below ###
function warnMe {
    # you get a short message with the relevant details on $1
    # (the argument 1)
    echo "warnMe isn't configured on failover.sh"
}

### You probably don't neet to worry about the rest ###

promoteCommand="touch /tmp/promotedb"
redirectCommand="sudo service postgresql-9.4 restart"

sshOptions="-o ConnectTimeout=5"

detachedNodeID=$1   # %d
echo "detachedNodeID: $detachedNodeID"

newMasterID=$6      # %m
echo "newMasterID: $newMasterID"
newMasterIP=$7      # %H
echo "newMasterIP: $newMasterIP"
oldMasterID=$8      # %P
echo "oldMasterID: $oldMasterID"
newMasterPort=$9    # %r
echo "newMasterPort: $newMasterPort"

if [[ $detachedNodeID != $oldMasterID ]]; then
    echo "a slave went dark, do nothing"
    warnMe "Slave "$1" on "$2" was detached from PgPool"
    exit 0
fi

echo "master went dark, execute failover protocol"

ssh -t $sshOptions $sudoUser@$newMasterIP  "$promoteCommand"

tmpfile=hopeImNotOverwritingAnything
function createRecovery.conf {
    echo "standby_mode=on" > $tmpfile
    echo "trigger_file='/tmp/promotedb'" >> $tmpfile
    echo "primary_conninfo='host=$newMasterIP port=$newMasterPort user=replicador application_name=postgresql$1'" >> $tmpfile
    echo "recovery_target_timeline='latest'" >> $tmpfile
}

for nodeID in ${nodeIDs[@]}
do
    if [[ $nodeID != $newMasterID && $nodeID != $detachedNodeID ]];then
        createRecovery.conf $nodeID
        scp $sshOptions $tmpfile $postgresUser@${nodeIPs[$nodeID]}:"$dataFolder"recovery.conf
        rm $tmpfile
        echo "restart node $nodeID"
        ssh -t $sshOptions $sudoUser@${nodeIPs[$nodeID]} "$redirectCommand"
        echo "reattach node $nodeID"
        pcp_attach_node 10 localhost $pcpport $pcpuser $pcppass $newMasterID
    fi
done

warnMe "The Master (ID: "$1" IP: "$2") was detached from PgPool, failed over to node "$6" IP:"$7""

echo "-----"
exit 1
