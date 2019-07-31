#!/bin/bash
set -vx
OLD_CONTAINER=$(docker container ls --filter='name=npcfn' --quiet )
docker kill $OLD_CONTAINER
docker container prune -f --filter='name=npcfn'
docker build --rm -f "Dockerfile" -t nagios-plugins-cloudformation:latest .
CONTAINER=$(docker create -p 8080:8080 --name=npcfn nagios-plugins-cloudformation)
echo $CONTAINER
docker container ls --all
docker inspect $CONTAINER
docker cp ~/.aws/config $CONTAINER:/root/.aws/
docker cp ~/.aws/credentials $CONTAINER:/root/.aws/
docker start -i $CONTAINER &
COUNTER=0
while [ $(docker ps | wc -l) -le 1 ] && [COUNTER -le 20]
do
    docker ps
    echo "waiting for docker start"
    COUNTER=$((COUNTER +1))
    sleep 1
done


COUNTER=0
curl http://127.0.0.1:8080
while [ $? -ne 0 ] && [COUNTER -le 20]
do
    sleep 1
    COUNTER=$((COUNTER +1))
    curl http://127.0.0.1:8080
done

docker kill $CONTAINER
docker container prune -f --filter='name=npcfn'
echo $CONTAINER