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

# Jenkins SSH-Agent Using Docker
I installed Docker pipeline plugin to use docker image later (not sure if it was necessary on top of installing all suggested pluging)<br>
I created rsa public/private key called `jrsa` without any passphrase under temp folder<br>
`ssh-keygen -t rsa -f jrsa`<br>
The content of private key `jrsa` will be used in Controller, and the content of `jrsa.pub` added to Dockerfile-[compose-file](./agent/agent1/compose.yml) for environment variable `JENKINS_AGENT_SSH_PUBKEY`<br>
please note that the docker-image `jenkins/ssh-agent:alpine`, has a user called `jenkins` with home at `/home/jenkins` and we have a working directory for agent in `/home/jenkins/agent`, and the hostname will be what we set in docker-compose file as `jenkinsagent1`, also this image has `ssh-server` running and listening on default port `22`; (we can get all this information before creating compose file see [note.md](./note.md) file)<br>
we can bring up or down the agent using
- `make agent-up`
- `make agent-down`
<br>
to test
- manage jenkins, manage Nodes and Clouds, new node agent1, type permanent Agent, create
- remote root directory= /home/jenkins
- labels= agent1
- new-item, run-in-agent1, freestyle
- general, restrict where this project run
- launch method= Launc agents via SSH
- Host = jenkinsagent1
 - credintials-add - jenkins
 - kind = SSH username with private key
 - username = jenkins
 -private enter directly-add , paste jrsa content,  save
 - Host Key Verification Strategy= Manually trusted key verification strategy, save
 <br>
 - http://localhost:8080/manage/computer/(built-in)/configure set Number of executor from default 2 to 0
 <br>
- new item, run-in-agent1, freestyle
- general: restrict where this project can be run, label expression=agent1
- build step=shell executor, echo $NODE_NAME
- apply, save and build
- check console output
<br>
```console
Started by user admin
Running as SYSTEM
Building remotely on agent1 in workspace /home/jenkins/workspace/run-in-agent1
[run-in-agent1] $ /bin/sh -xe /tmp/jenkins13018415910130766617.sh
+ echo agent1
agent1
Finished: SUCCESS
```
<br>
see [this](https://github.com/jenkinsci/configuration-as-code-plugin/blob/master/README.md), we may use [JCasC](https://www.jenkins.io/projects/jcasc/#configure-all-jenkins-initial-setup), to configure the credintials, and nodes.
<br>
we can create a custom ssh-agent (not using the jenkins/ssh-agent), but we may need to do more setting see [this](https://github.com/mc1496/jenkins2-jenkins-course/blob/master/jenkins-slave/Dockerfile)
<br>
