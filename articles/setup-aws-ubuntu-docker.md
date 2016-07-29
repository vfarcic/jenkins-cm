AWS - Ubuntu - Docker
=====================

```bash
export TF_VAR_ssh_user=devops

export TF_VAR_ssh_pass=devops

export TF_VAR_aws_access_key=<ACCESS KEY ID>

export TF_VAR_aws_secret_key=<SECRET ACCESS KEY>
```

CJE
---

* Make sure that your license is stored in the ansible/roles/cje/files/license.xml file

### Create & Provision AMI

```bash
packer build -machine-readable packer-cje-docker.json | tee packer-cje-docker.log
```

### Create instances

TODO: Continue

```bash
export TF_VAR_cje_ami_id=$(grep 'artifact,0,id' packer-cje-docker.log | cut -d, -f6 | cut -d: -f2)

terraform apply -target aws_instance.cje_docker -var "cje_count=1"
```

### SSH

```bash
ssh $TF_VAR_ssh_user@$(terraform output cje_public_ip_0)

ssh $TF_VAR_ssh_user@$(terraform output cje_public_ip_1)
```

### Destroy

```bash
terraform destroy -force -target aws_instance.cje_docker
```

TODO
----

* Switch to Ubuntu 16.04
* Remove mode 777