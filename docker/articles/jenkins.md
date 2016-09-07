# Jenkins

## OSS

```bash
docker-machine create -d virtualbox jenkins

eval $(docker-machine env jenkins)

docker-compose up -d jenkins

open http://$(docker-machine ip jenkins):8080
```

## CJE

```bash
docker-machine create -d virtualbox cje-1

eval $(docker-machine env cje-1)

docker-compose up -d cje

open http://$(docker-machine ip cje-1):8080
```

## CJOC

```bash
docker-machine create -d virtualbox cjoc-1

eval $(docker-machine env cjoc-1)

docker-compose up -d cjoc

open http://$(docker-machine ip cjoc-1):8080
```

## Agent

* Install the Swarm plugin

```bash
docker-machine create -d virtualbox agent

eval $(docker-machine env agent)

export MASTER_IP=$(docker-machine ip jenkins)

docker-compose up -d agent
```