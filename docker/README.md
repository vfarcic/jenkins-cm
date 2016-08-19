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

Agent
-----

```bash

```

ES
--

```bash
docker-machine create -d virtualbox es

eval $(docker-machine env es)

docker-compose up -d es

export ES_IP=$(docker-machine ip es)

docker-compose up -d kibana

open http://${ES_IP}:5601

# https://cloudbees.atlassian.net/browse/CJP-5066
```

Agent
-----

```bash
docker-machine create -d virtualbox agent

eval $(docker-machine env agent)

export MASTER_IP=$(docker-machine ip cje-1)

docker-compose up -d agent
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
    sh "docker-compose -f docker-compose-test.yml run --rm unit"
    sh "docker build -t go-demo ."
    sh "cat unit.out | grep coverage | cut -d' ' -f2- | cut -d'%' -f1  | tr -d '\n' >coverage.out"
    coverage = readFile "coverage.out"

    stage 'analytics'
    sh "git rev-list HEAD -n 1 | tr -d '\n' >rev.tmp"
    rev = readFile 'rev.tmp'
/*
    sh "curl -XPOST -d '{" +
      "\"@timestamp\": \"2016-08-19T22:55:24.593+0000\", " +
      "\"type\": \buildinfo\", " +
      "\"job_name\": \"${env.JOB_NAME}\", " +
      "\"job_id\": ${env.BUILD_ID}, " +
      "\"rev\": \"${rev}\", " +
      "\"coverage\": ${coverage} " +
      "}' " +
      "http://192.168.99.102:9200/builds-20160819/buildinfo/${env.JOB_NAME}-${env.BUILD_ID}"
*/
    writeFile(
      "logstash.out",
      "{" +
        "\"type\": \buildinfo\", " +
        "\"job_name\": \"${env.JOB_NAME}\", " +
        "\"job_id\": ${env.BUILD_ID}, " +
        "\"rev\": \"${rev}\", " +
        "\"coverage\": ${coverage} " +
      "}"
    )
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
type: "run" AND parent.fullName: "test-1"

_type: "buildinfo" AND job_name: "test-1"
```

### Export

```bash
docker run --rm vfarcic/elastic-dump \
    --input=http://$(docker-machine ip es):9200/kibana-4-cloudbees \
    --output=$ \
    --type=data >es-kibana.json
```

### Visualizations

* Builds Over Time
* Average Build Duration
* Latest Builds
* Total Builds

### Dashboards

* job-test-1