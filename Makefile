#Controller via docker-compose file

export SERVER_COMPOSE_FILE=./controller/compose.yml
export INIT_PASS_FILE=/var/jenkins_home/secrets/initialAdminPassword

server-up:
	docker compose -f $${SERVER_COMPOSE_FILE} up -d
	echo "http://localhost:8080"

server-down:
	docker compose -f $${SERVER_COMPOSE_FILE} down

server-bash:
	docker exec -it jenkins-server /bin/bash

server-init-pass:
	docker exec -it jenkins-server cat $${INIT_PASS_FILE}

server-destroy:
	docker compose -f $${SERVER_COMPOSE_FILE} down --volumes

# grep with empyth results in bash is OK, but in make results in error due to non-zero exit code
# or with true which has zero exit code
server-list-info:
	#docker ps | grep -oh jenkins-server || true
	#docker container ls | grep -oh jenkins-server || true
	docker network ls | grep -oh jenkins-net || true
	docker volume ls | grep -oh jenkins-cfg || true

######################################################################
# to see the commands of a targetrun make target V=s (Verbose=Set)
# otherwise make target does not print/show the commands under target
$(V).SILENT:

