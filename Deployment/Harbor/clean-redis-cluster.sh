# ITNOA

#!/bin/bash

if [[ ! -f "harbor-redis-cluster.yaml" ]] ; then
    echo "harbor-redis-cluster.yaml does not found!"
    exit 1
fi

kubectl delete -f harbor-redis-db.yaml
kubectl delete -f harbor-redis-cluster.yaml

# TODO: Input from user
if false ; then

    # For cluster recovery https://docs.redis.com/latest/kubernetes/re-clusters/cluster-recovery/
    kubectl patch rec <cluster-name> --type merge --patch '{"spec":{"clusterRecovery":true}}'

    # REDB Deletion
    # If for some reason the user ends up with an REDB resource that can't be deleted,
    # because the finalizer can't be removed, they can remove the finalizer manually by editing the REDB resource.
    # For example, if the REDB name is redis-enterprise-database, here is a command to remove its finalizer manually
    #
    # For more information, Please see https://github.com/RedisLabs/redis-enterprise-k8s-docs/blob/master/topics.md#rec-deletion
    kubectl patch redb redis-enterprise-database --type=json -p '[{"op":"remove","path":"/metadata/finalizers","value":"finalizer.redisenterprisedatabases.app.redislabs.com"}]'

fi
