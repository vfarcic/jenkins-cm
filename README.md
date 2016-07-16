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
```

### Create instances

```bash
export TF_VAR_cje_ami_id=$(grep 'artifact,0,id' packer-cje-centos.log | cut -d, -f6 | cut -d: -f2)

export TF_VAR_cjoc_ami_id=$(grep 'artifact,0,id' packer-cjoc-centos.log | cut -d, -f6 | cut -d: -f2)

export TF_VAR_ha_ami_id=$(grep 'artifact,0,id' packer-ha-centos.log | cut -d, -f6 | cut -d: -f2)

terraform apply
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

terraform apply -target aws_instance.cje
```

### SSH

```bash
ssh $TF_VAR_ssh_user@$(terraform output cje_public_ip_0)

ssh $TF_VAR_ssh_user@$(terraform output cje_public_ip_1)
```

### Destroy

```bash
terraform destroy -force -target aws_instance.cje
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
```

### SSH

```bash
ssh $TF_VAR_ssh_user@$(terraform output ha_public_ip)
```

### Destroy a single instance

```bash
terraform destroy -force -target aws_instance.ha
```

Vagrant - CentOS - Package
==========================

* Make sure that your license is stored in the ansible/roles/cje/files/license.xml file

CJE
---

### Create VM

```bash
vagrant up cje-centos-1 cje-centos-2
```

### Provision

```bash
ansible-playbook ansible/cje.yml \
    -i ansible/hosts/centos \
    --extra-vars "copy_license=yes"
```

CJOC
----

```bash
vagrant up cjoc-centos-1 cjoc-centos-2

# Only if HA is used
# Does NOT work with Vagrant
#ansible-playbook ansible/nfs-client.yml \
#    -i ansible/hosts/centos \
#    --extra-vars "src_nfs_dir=/var/nfs/jenkins-oc dest_nfs_dir=/var/lib/jenkins-oc hosts_group=cjoc"

ansible-playbook ansible/cjoc.yml \
    -i ansible/hosts/centos \
    --extra-vars "copy_license=yes"
```

HA
--

### Note: HA does not work with CJEs and CJOCs running inside Vagrant

```bash
vagrant up ha-centos

#ansible-playbook ansible/nfs-server.yml \
#    -i ansible/hosts/centos \
#    --extra-vars "nfs_dir=/var/nfs/jenkins-oc nfs_client_ip=10.100.199.201"

#ansible-playbook ansible/nfs-server.yml \
#    -i ansible/hosts/centos \
#    --extra-vars "nfs_dir=/var/nfs/jenkins-oc nfs_client_ip=10.100.199.202"

ansible-playbook ansible/ha.yml \
    -i ansible/hosts/centos \
    --extra-vars "cjoc_ip_1=10.100.199.201 cjoc_ip_2=10.100.199.202"
```

TODO
====

* HA

  * Vagrant Ubuntu
  * Vagrant Docker
  * AWS
  * Azure
  * DigitalOcean

* CJOC

  * Vagrant Ubuntu
  * Vagrant Docker
  * AWS
  * Azure
  * DigitalOcean
