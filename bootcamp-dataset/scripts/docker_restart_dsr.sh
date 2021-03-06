#! /bin/bash

# re-launch DSR docker

# Get the MapR Cluster name
MAPR_CLUSTER_NAME=`head -n 1 /opt/mapr/conf/mapr-clusters.conf | awk '{print $1}'`

# Get the CLDB hostname
MAPR_CLDB_HOST_NAME=`head -n 1 /opt/mapr/conf/mapr-clusters.conf | awk '{print $3}'`
MAPR_CLDB_HOST_NAME=${MAPR_CLDB_HOST_NAME%:7222}

# Get the mapr uid and gid
MAPR_UID=`id -u mapr`
MAPR_GID=`id -g mapr`


# Kill DSR docker if currently running
docker ps | awk '{ print $1,$2 }' | grep data-science-refinery | awk '{print $1 }' | xargs -I {} docker kill {}


# Launch the docker container
docker run -it \
--cap-add SYS_ADMIN \
--cap-add SYS_RESOURCE \
--device /dev/fuse \
--restart=always \
-e HOST_IP=$MAPR_CLDB_HOST_NAME \
-e MAPR_CLUSTER=$MAPR_CLUSTER_NAME \
-e MAPR_CLDB_HOSTS=$MAPR_CLDB_HOST_NAME \
-e MAPR_CONTAINER_USER=mapr \
-e MAPR_CONTAINER_PASSWORD=mapr \
-e MAPR_CONTAINER_GROUP=mapr \
-e MAPR_CONTAINER_UID=$MAPR_UID \
-e MAPR_CONTAINER_GID=$MAPR_GID \
-e MAPR_MOUNT_PATH=/mapr \
-p 9995:9995 \
-p 10000-10010:10000-10010 \
maprtech/data-science-refinery &
