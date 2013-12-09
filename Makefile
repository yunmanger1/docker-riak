all: riak-container

riak-container:
	docker -H=$$DOCKER_API_HOST build -t "hectcastro/riak" .

start-cluster:
	./bin/start-cluster.sh

test-cluster:
	./bin/test-cluster.sh

stop-cluster:
	./bin/stop-cluster.sh
