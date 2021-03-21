mssql-up:
	docker-compose -f ./docker/docker-compose-sqlserver.yaml up -d
	
mssql-start:
	docker start mssql

mongo-up:
	docker-compose -f ./docker/docker-compose-mongo.yaml up -d
	
mongo-start:
	docker start mongo

redis-up:
	docker-compose -f ./docker/docker-compose-redis.yaml up -d
	
redis-start:
	docker start redis

logsclusterup:
	#grep vm.max_map_count /etc/sysctl.conf
	#vm.max_map_count=262144
	docker-compose -f ./docker/docker-compose-logs-multi-cluster.yaml up -d

logsup:
	docker-compose -f ./docker/docker-compose-logs.yaml up -d

logsclstart:
	docker start es01
	docker start es02
	docker start es03
	docker start kibana


logs-start:
	docker start elasticsearch
	docker start kibana

logsstop:
	docker stop kibana
	docker stop elasticsearch
	
logsreset:
	make logsstop
	docker rm kibana
	docker rm elasticsearch
	
	docker volume rm docker_elasticsearch-data

mysql-up:
	docker-compose -f ./docker/docker-compose-mysql.yaml stop
	docker-compose -f ./docker/docker-compose-mysql.yaml build
	docker-compose -f ./docker/docker-compose-mysql.yaml up -d

mysql-start:
	docker start mysql


reset:
	make stop
	#remove os containers
	docker rm kibana
	docker rm elasticsearch
	docker rm mysql
	#remove as imagens
	docker rmi db_mysql

#--->> KUBERNETES
#LOGS: ELASTICSEARCH, KIBANA
kslogs-up:
	#Cria infra Logs
	kubectl apply -f ./k8s/infra/logs/elasticsearch-ss.yaml
	kubectl apply -f ./k8s/infra/logs/kibana-deployment.yaml

kslogs-down:
	#Delete Logs
	kubectl delete statefulsets elasticsearch-logging
	kubectl delete services elasticsearch-logging
	#kubectl delete deployments kibana-logging
	#kubectl delete services kibana-logging

# DATABASE: MYSQL
ksdb-up:
	#Cria infra banco de dados
	kubectl apply -f ./k8s/infra/mysql/pv.yaml
	kubectl apply -f ./k8s/infra/mysql/deployment.yaml
	kubectl apply -f ./k8s/infra/mysql/loadbalance.yaml

ksdb-down:
	kubectl delete deployments mysql
	kubectl delete services mysql
	kubectl delete PersistentVolumeClaim mysql-pv-claim

#API
ksapi-up:
	#Cria Api
	kubectl apply -f ./k8s/api/secrets.yaml
	kubectl apply -f ./k8s/api/deployment.yaml
	kubectl apply -f ./k8s/api/loadbalance.yaml

ksapi-down:
	kubectl delete deployments cadcliente-api-deployment
	kubectl delete services cadcliente-api-service
	kubectl delete secrets cadcliente-api-secret

gcks-up:
	gcloud container clusters create cadclienteapi
	#make kslogs-up
	make ksdb-up
	#make ksapi-up

gcup:
	#prepara a imagem para o container
	#make api
	#docker tag cadastro_cliente_api gcr.io/devops-learn-304501/cadcliente-api:v1
	docker push gcr.io/devops-learn-304501/cadcliente-api:v1

	#kubernetes
	make gcks-up
gcapi-up:
	make api
	docker tag cadastro_cliente_api gcr.io/devops-learn-304501/cadcliente-api:v1
	docker push gcr.io/devops-learn-304501/cadcliente-api:v1
	make ksapi-up

k8s-down:
	#kubernetes
	make ksapi-down
	make kslogs-down
	make ksdb-down

gcdown-all:
	make k8s-down
	gcloud container clusters delete cadclienteapi

	#exclui a imagem do Gogle Artifact Registry
	gcloud container images delete gcr.io/devops-learn-304501/cadcliente-api:v1  --force-delete-tags --quiet
