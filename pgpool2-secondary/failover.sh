#! /bin/bash

# please enter your config stuff

nodeIDs=( 0 1 2 )
nodeIPs=(   
            192.168.129.123 
            192.168.129.143 
            192.168.129.202 
        )

nodePorts=( 5432 5432 5432 )

promoteCommand="touch /tmp/promotedb"
redirectCommand="sudo service postgresql-9.4 restart"

pcpport="9898"
pcpuser="postgres"
pcppass="postgres"


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
    exit 0
fi

echo "master went dark, execute failover protocol"

ssh -t admra@$newMasterIP  "$promoteCommand"

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
        echo "get to da file!"
        createRecovery.conf $nodeID
        scp $tmpfile postgres@${nodeIPs[$nodeID]}:/var/lib/pgsql/9.4/data/recovery.conf
        rm $tmpfile
        echo "restart node $nodeID"
        ssh -t admra@${nodeIPs[$nodeID]} "$redirectCommand"
        echo "reattach node $nodeID"
        pcp_attach_node 10 localhost $pcpport $pcpuser $pcppass $newMasterID
    fi
done

echo "-----"
