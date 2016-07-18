Restart Aborted Builds
======================

Execute a long running job

```bash
curl http://$(terraform output ha_public_ip):8080/job/long-running-job/build?delay=0sec

open http://$(terraform output ha_public_ip):8080/job/long-running-job/1/console
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

Confirm that the build is still running

```bash
open http://$(terraform output ha_public_ip):8080/job/long-running-job/1/console
```

Start the failed instance.

```bash
ssh -tq devops@$IP 'sudo service jenkins start'
```