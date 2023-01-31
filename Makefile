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



