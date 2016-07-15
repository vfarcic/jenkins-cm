CJE
===

Vagrant - CentOS - Package
--------------------------

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

AWS - CentOS - Package
----------------------

### Create & Provision AMI

```bash
export SSH_USER=devops

export SSH_PASS=devops

export AWS_ACCESS_KEY=<ACCESS KEY ID>

export AWS_SECRET_KEY=<SECRET ACCESS KEY>

packer validate \
    -var aws_access_key=$AWS_ACCESS_KEY \
    -var aws_secret_key=$AWS_SECRET_KEY \
    packer-cje-centos.json

packer build -machine-readable \
    -var aws_access_key=$AWS_ACCESS_KEY \
    -var aws_secret_key=$AWS_SECRET_KEY \
    packer-cje-centos.json | tee packer-cje-centos.log

export AMI_ID=$(grep 'artifact,0,id' packer-cje-centos.log | cut -d, -f6 | cut -d: -f2)

terraform apply \
    -var ami_id=$AMI_ID \
    -var aws_access_key=$AWS_ACCESS_KEY \
    -var aws_secret_key=$AWS_SECRET_KEY \
    -var ssh_user=$SSH_USER \
    -var ssh_pass=$SSH_PASS
```

### Provision

```bash
```

CJOC
====

Vagrant - CentOS - Package
--------------------------

* Make sure that your license is stored in the ansible/roles/cjoc/files/license.xml file

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
==

Vagrant - CentOS - Package
--------------------------

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
