# Jenkins Server using Docker

This readme contains steps to bring up Docker-version of Jenkins-server using docker-compose, and related commands organized in the [Makefile](./Makefile) of this repo. To simplify this readme, extra notes collected in [node.md](./note.md).<br>
We assume the docker is properly running on the system.

## bring up server
`make server-up`<br>

## access Jenkins web-UI
`http://localhost:8080`<br>
login or follow next section if this is first time, and server not initialize yet.

### get server-init-password
If this is the first time we bring up the server we need initial-pass to continue, and we can get it by following command<br>
`make server-init-pass`<br>

### initialize the server
- install suggested plugins (we can choose other option, and then we can select All,None, suggested, or ...)
- create first admin user, I set everything as admin and added my email (we may need user during ssh access to cli, so better to use simple name)
- leave Jenkins URL as it is
- save and finish, start using Jenkins

## access Jenkins CLI
obviously we need access to server-terminal to run some command-line operation using Jenkins CLI tool, one easy way to use docker to get access to bash as follow
### access server bash
`make server-bash`<br>
now we can continue prepration for using Jenkins CLI tool, by creating a zdata folder in jenkins-home folder which is persistant by using docker-volume. and generate ssh-key without passphrase to set it up for admin user
```console
root@jenkinsserver:/var/jenkins_home# mkdir zdata
root@jenkinsserver:/var/jenkins_home# cd zdata
root@jenkinsserver:/var/jenkins_home/zdata# ssh-keygen -t rsa -f admin-rsa
root@jenkinsserver:/var/jenkins_home/zdata# ls
admin-rsa  admin-rsa.pub
root@jenkinsserver:/var/jenkins_home/zdata# cat admin-rsa.pub
```
- http://localhost:8080/manage/configureSecurity/ select Random for SSH-server-port apply/save
- ssh-keygen -t rsa, location: /home/max/.ssh/jenkins_rsa, no pass-phrase
- copy the result of cat admin-rsa.pub in above snippet, and paste the content to SSH in http://localhost:8080/user/admin/configure then apply/save
- go to http://localhost:8080/cli/, and copy the link for `jenkins-cli.jar` download
- go back to server-terminal and download it as follow
```console
root@jenkinsserver:/var/jenkins_home/zdata#
root@jenkinsserver:/var/jenkins_home/zdata# curl http://localhost:8080/jnlpJars/jenkins-cli.jar --output jenkins-cli.jar
root@jenkinsserver:/var/jenkins_home/zdata# ls
admin-rsa  admin-rsa.pub  jenkins-cli.jar
root@jenkinsserver:/var/jenkins_home/zdata#
```
- `java -jar jenkins-cli.jar -s http://localhost:8080/ -ssh -user admin -i admin-rsa help`
- if we see issue (WARNING) with /root/.ssh/known_hosts and ...; we can just create a dummy rsa or (`ssh-keygen -t rsa` then few **enters** to accepet all default); unfortunatly this will not part of our docker-volume, unless we add another mapping if it worth it, and we may run this fix once if server go down and come back. Also we may create shell script to simplify the long commands for cli-access; Anyway, for now we leave it as it is. even custom location of rsa-file cannot help us see [this](https://stackoverflow.com/questions/84096/setting-the-default-ssh-key-location)







