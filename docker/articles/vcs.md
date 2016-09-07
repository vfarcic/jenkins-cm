# VCS

```bash
docker-machine create -d virtualbox vcs

eval $(docker-machine env vcs)
```

## Git

```groovy
node("docker") {

    git "https://github.com/vfarcic/go-demo.git"

}
```

## SVN

```bash
docker-compose up -d svn

svn info svn://$(docker-machine ip vcs):3690/repos

docker-compose run svn sh

apt-get update

apt-get install -y git

git clone https://github.com/vfarcic/go-demo.git

svn import -m "Initial commit" go-demo file:////var/svn/repos/go-demo

exit

svn co svn://$(docker-machine ip vcs)/repos/go-demo

echo "
node('docker') {

    svn 'svn://$(docker-machine ip vcs)/repos/go-demo'

}
"
```

## CVS

```bash

```
