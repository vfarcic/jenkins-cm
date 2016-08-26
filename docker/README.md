CJE
---

```bash
docker-machine create -d virtualbox cje-1

eval $(docker-machine env cje-1)

docker-compose up -d cje

open http://$(docker-machine ip cje-1):8080
```

CJOC
----

```bash
docker-machine create -d virtualbox cjoc-1

eval $(docker-machine env cjoc-1)

docker-compose up -d cjoc

open http://$(docker-machine ip cjoc-1):8080
```

ELK
---

```bash
docker-machine create -d virtualbox elk

eval $(docker-machine env elk)

docker-compose up -d elasticsearch

# https://cloudbees.atlassian.net/browse/CJP-5066

docker-machine ssh elk "nohup curl --unix-socket /var/run/docker.sock http:/events >/var/log/docker.events &"

cd logstash

docker build -t vfarcic/logstash-jenkins-analytics .

cd ..

docker-compose up -d logstash

docker-compose up -d kibana

docker-compose logs -f

open http://$(docker-machine ip elk):5601
```

Jenkins
-------

```bash
docker-machine create -d virtualbox jenkins

eval $(docker-machine env jenkins)

docker-compose up -d jenkins

open http://$(docker-machine ip jenkins):8080
```

* Install the Swarm plugin

Agent
-----

```bash
docker-machine create -d virtualbox agent

eval $(docker-machine env agent)

export MASTER_IP=$(docker-machine ip jenkins)

docker-compose up -d agent
```

GitLab
------

```bash
docker-compose up -d gitlab

open http://localhost:8080
```

Job
---

* TODO: Make 192.168.99.102 dynamic
* TODO: Make 20160819 dynamic

```bash
curl -XPUT http://192.168.99.102:9200/kibana-4-cloudbees -d '
{
  "mappings" : {
    "job-info": {
      "properties": {
        "_timestamp" : { "enabled" : true, "store" : true }
      }
    }
  }
}'
```

```groovy
node('docker') {

    git 'https://github.com/vfarcic/go-demo.git'

    stage 'Unit'
    sh "docker-compose -f docker-compose-test.yml run --rm unit | tee unit.out"
    sh "docker build -t go-demo ."
    sh "cat unit.out | grep coverage | cut -d' ' -f2- | cut -d'%' -f1  | tr -d '\n' >coverage.out"
    coverage = readFile "coverage.out"

    stage 'analytics'
    sh "git rev-list HEAD -n 1 | tr -d '\n' >rev.tmp"
    rev = readFile 'rev.tmp'

    sh "curl -XPUT -d '{" +
      "\"action\": \"build\", " +
      "\"job_name\": \"${env.JOB_NAME}\", " +
      "\"job_id\": ${env.BUILD_ID}, " +
      "\"rev\": \"${rev}\", " +
      "\"coverage\": ${coverage} " +
      "}' " +
      "http://192.168.99.100:31311/"
}
```

```bash
curl "http://$(docker-machine ip es):9200/builds-20160819/buildinfo/_search?pretty=true"

curl "http://$(docker-machine ip es):9200/builds-20160819/buildinfo/_search?pretty=true&q=job_id:78"
```

Kibana
------

### Discover

```
type: "git" AND object_kind: "push" AND repository.name: "test-1"

type: "git" AND object_kind: "issue" AND repository.name: "test-1"

type: "git" AND object_kind: "issue" AND object_attributes.state: "opened" AND repository.name: "test-1"

type: "git" AND object_kind: "issue" AND object_attributes.state: "closed" AND repository.name: "test-1"

type: "docker"

type: "docker" AND (status: "start" OR status: "destroy")

type: "run" AND parent.fullName: "test-1"

_type: "buildinfo" AND job_name: "test-1"
```

### Export

```bash
docker run --rm vfarcic/elastic-dump \
    --input=http://$(docker-machine ip elk):9200/.kibana \
    --output=$ \
    --type=data >es/kibana.json
```

### Visualizations

* Builds Over Time
* Average Build Duration
* Latest Builds
* Total Builds

### Dashboards

* job-test-1