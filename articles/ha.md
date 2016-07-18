High Availability
=================

CJE
---

### Check the status of each instance.

```bash
open http://$(terraform output cje_public_ip_0):8080

open http://$(terraform output cje_public_ip_1):8080
```

> One of the two instances should say that *this node is standing by in case the primary node fails over*.

### Simulate failure

Open through HAProxy.

```bash
open http://$(terraform output ha_public_ip):8080
```

Stop the primary instance.

```bash
if [ $(curl -I http://$(terraform output cje_public_ip_0):8080 | head -n 1| cut -d$' ' -f2) == 200 ];
then
  export IP=$(terraform output cje_public_ip_0)
else
  export IP=$(terraform output cje_public_ip_1)
fi
ssh -tq devops@$IP 'sudo service jenkins stop'
```

Open through HAProxy.

```bash
open http://$(terraform output ha_public_ip):8080
```

> Jenkins is still running

Start the failed instance.

```bash
ssh -tq devops@$IP 'sudo service jenkins start'
```

CJOC
----

### Check the status of each instance.

```bash
open http://$(terraform output cjoc_public_ip_0):8888

open http://$(terraform output cjoc_public_ip_1):8888
```

> One of the two instances should say that *this node is standing by in case the primary node fails over*.

### Simulate failure

Open through HAProxy.

```bash
open http://$(terraform output ha_public_ip)
```

Stop the primary instance.

```bash
if [ $(curl -I http://$(terraform output cjoc_public_ip_0):8888 | head -n 1| cut -d$' ' -f2) == 200 ];
then
  export IP=$(terraform output cjoc_public_ip_0)
else
  export IP=$(terraform output cjoc_public_ip_1)
fi
ssh -tq devops@$IP 'sudo service jenkins-oc stop'
```

Open through HAProxy.

```bash
open http://$(terraform output ha_public_ip)
```

> Jenkins OC is still running

Start the failed node.

```bash
ssh -tq devops@$IP 'sudo service jenkins-oc start'
```