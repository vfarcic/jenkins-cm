HA
==

Vagrant CentOS
--------------

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

CJOC
====

Vagrant CentOS
--------------

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

CJE
===

Vagrant CentOS
--------------

```bash

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
