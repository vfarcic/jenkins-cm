AWS - CentOS - Package
======================

```bash
export TF_VAR_ssh_user=devops

export TF_VAR_ssh_pass=devops

export TF_VAR_aws_access_key=<ACCESS KEY ID>

export TF_VAR_aws_secret_key=<SECRET ACCESS KEY>
```

All (HA Proxy + 2 x CJE in HA + 2 x CJOC in HA)
-----------------------------------------------

### Create & Provision AMIs

```bash
packer build -machine-readable packer-cje-centos.json | tee packer-cje-centos.log

packer build -machine-readable packer-cjoc-centos.json | tee packer-cjoc-centos.log

packer build -machine-readable packer-ha-centos.json | tee packer-ha-centos.log

packer build -machine-readable packer-agent-centos.json | tee packer-agent-centos.log
```

### Create instances

```bash
export TF_VAR_cje_ami_id=$(grep 'artifact,0,id' packer-cje-centos.log | cut -d, -f6 | cut -d: -f2)

export TF_VAR_cjoc_ami_id=$(grep 'artifact,0,id' packer-cjoc-centos.log | cut -d, -f6 | cut -d: -f2)

export TF_VAR_ha_ami_id=$(grep 'artifact,0,id' packer-ha-centos.log | cut -d, -f6 | cut -d: -f2)

export TF_VAR_agent_ami_id=$(grep 'artifact,0,id' packer-agent-centos.log | cut -d, -f6 | cut -d: -f2)

terraform apply

open http://$(terraform output ha_public_ip)

open http://$(terraform output ha_public_ip):8080
```

### Destroy

```bash
terraform destroy -force
```

CJE
---

* Make sure that your license is stored in the ansible/roles/cje/files/license.xml file

### Create & Provision AMI

```bash
packer build -machine-readable packer-cje-centos.json | tee packer-cje-centos.log
```

### Create instances

```bash
export TF_VAR_cje_ami_id=$(grep 'artifact,0,id' packer-cje-centos.log | cut -d, -f6 | cut -d: -f2)

terraform apply -target aws_instance.cje_centos -var "cje_instance_type=m3.medium"
```

### SSH

```bash
ssh $TF_VAR_ssh_user@$(terraform output cje_public_ip_0)

ssh $TF_VAR_ssh_user@$(terraform output cje_public_ip_1)
```

### Destroy

```bash
terraform destroy -force -target aws_instance.cje_centos
```

CJOC
----

* Make sure that your license is stored in the ansible/roles/cjoc/files/license.xml file

### Create & Provision AMI

```bash
packer build -machine-readable packer-cjoc-centos.json | tee packer-cjoc-centos.log
```

### Create instances

```bash
export TF_VAR_cjoc_ami_id=$(grep 'artifact,0,id' packer-cjoc-centos.log | cut -d, -f6 | cut -d: -f2)

terraform apply -target aws_instance.cjoc
```

### SSH

```bash
ssh $TF_VAR_ssh_user@$(terraform output cjoc_public_ip_0)

ssh $TF_VAR_ssh_user@$(terraform output cjoc_public_ip_1)
```

### Destroy

```bash
terraform destroy -force -target aws_instance.cjoc
```

HA
--

### Create & Provision AMI

```bash
packer build -machine-readable packer-ha-centos.json | tee packer-ha-centos.log
```

### Create instances

```bash
export TF_VAR_ha_ami_id=$(grep 'artifact,0,id' packer-ha-centos.log | cut -d, -f6 | cut -d: -f2)

terraform apply -target aws_instance.ha

open http://$(terraform output ha_public_ip)

open http://$(terraform output ha_public_ip):8080
```

### SSH

```bash
ssh $TF_VAR_ssh_user@$(terraform output ha_public_ip)
```

### Destroy a single instance

```bash
terraform destroy -force -target aws_instance.ha
```

Agents
------

* Make sure that your license is stored in the ansible/roles/cje/files/license.xml file

### Create & Provision AMI

```bash
packer build -machine-readable packer-agent-centos.json | tee packer-agent-centos.log
```

### Create instances

```bash
export TF_VAR_agent_ami_id=$(grep 'artifact,0,id' packer-agent-centos.log | cut -d, -f6 | cut -d: -f2)

terraform apply -target aws_instance.agent
```

### SSH

```bash
ssh $TF_VAR_ssh_user@$(terraform output agent_public_ip_0)

ssh $TF_VAR_ssh_user@$(terraform output agent_public_ip_1)
```

### Destroy

```bash
terraform destroy -force -target aws_instance.agent
```

TODO
----

* Fix JNLP port to 35464
* Fix Swarm agent connection to HAProxy
* Protect with user/pass (CJOC and CJE)
* Do not expose ports (except 80 and 8080 in HA)