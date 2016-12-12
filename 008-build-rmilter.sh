#!/bin/bash

. mailcow.conf

NAME="rmilter-mailcow"

echo "Stopping and removing containers with name tag ${NAME}..."
if [[ ! -z $(docker ps -af "name=${NAME}" -q) ]]; then
	docker stop $(docker ps -af "name=${NAME}" -q)
	docker rm $(docker ps -af "name=${NAME}" -q)
fi

build() {
	docker build --no-cache -t rmilter data/Dockerfiles/rmilter/.
}

if [[ ! -z "$(docker images -q rmilter)" ]]; then
    read -r -p "Found image locally. Delete local and rebuild without cache anyway? [y/N] " response
	response=${response,,}
	if [[ $response =~ ^(yes|y)$ ]]; then
		docker rmi rmilter
		build
	fi
else
	build
fi

docker run \
	-v ${PWD}/data/conf/rmilter/:/etc/rmilter.conf.d/:ro \
	--network=${DOCKER_NETWORK} \
	-h rmilter \
	--name ${NAME} \
	-d rmilter
