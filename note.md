# jenkins-server

We can use docker to run jenkins server/controller in our machine, and jenkins
[website](https://www.jenkins.io/doc/book/installing/docker/) has an example where it used  [docker:dind](https://hub.docker.com/layers/library/docker/dind/images/sha256-5c854de0db802a7922da1a271a969bd43c3c725cb6ea24953b217f3273aa1f2e?context=explore)
which is the official Docker in Docker image from docker. we use dind when we need to build or run docker in our jenkins-server while jenkins-server itself is running inside a docker; but it seems there are some concerns, and some other options for this purpose see
[this](https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/).
the above link refers to docker cli, and as reminder during docker installation on ubuntu we use the following command
<br>
`sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y`
<br>
where ce stands for Docker CE (Community Edition) vesrus Docker EE (Enterprise Edition);where based on [stackoverflow](https://stackoverflow.com/questions/58741267/containerd-io-vs-docker-ce-cli-vs-docker-ce-what-are-the-differences-and-what-d)
- containerd.io : daemon containerd. it is required by the docker packages.
- docker-ce-cli : command line interface for docker engine, community edition
- docker-ce : docker engine, community edition. Requires docker-ce-cli.

we may still need to install DOcker CLI inside our jenkins-docker;<br>
Also, when we use docker to run jenkins server, if we do not preserve all initial settings, they will be gone after stopping the corresponding docker image, and to preserve them we have to use docker volume to keep thoes settings. see [docker-doc](https://docs.docker.com/storage/volumes/) for more info on volume, how to create in compose file, or create using docker cli, then use it in compose, or benefit of creating volume instea of using existing folder in our file system as volume; called [bind-mount](https://docs.docker.com/storage/bind-mounts/).<br>
when we use docker-compose file, for bind-mount volume we need to be explicit and mention type as bind then source and target, or still we can use compact syntax as `source:targe`, and for named-volume we have to mentione them under volumes section in compose file, see more info [here](https://docs.docker.com/compose/compose-file/compose-file-v3/#volumes). Also some exmple at [compose.yml](./docker-compose/compose.yml)

## Jenkins Agents
It seems (*as I understand*) we can have two types of Agents:
- SSH Agent: Controller connect to Agent via SSH, and may start the agent, and even install JVM on it
- [JNLP](https://docs.oracle.com/javase/tutorial/deployment/deploymentInDepth/jnlp.html) Agent: This is a situation that controller cannot start remote agent, and we have to run it manually or some other way, then agent connect to controller;

### Note on JNLP
seems JNLP or webstart is kind od deprecated see [this](https://en.wikipedia.org/wiki/Java_Web_Start#Deprecation)<br>
but it seems we have docker image for that `docker pull jenkins/jnlp-slave:latest` also see [this](https://hub.docker.com/r/jenkins/jnlp-slave/tags)<br>
a good example for JNLP is [here](https://www.youtube.com/watch?v=62iKhvVl08Y)
<br>
also see [jemkins-remoting](https://www.jenkins.io/projects/remoting/)



### SSH Agent
let see some info on `jenkins/ssh-agent:alpine` docker image
```console
max@m20:~$ docker run -d jenkins/ssh-agent:alpine
max@m20:~$ docker ps | grep jenkins
306d0b718aef   jenkins/ssh-agent:alpine   "setup-sshd"   54 seconds ago   Up 49 seconds   22/tcp    cool_noether
max@m20:~$ docker exec -it 306d0b718aef /bin/bash
306d0b718aef:/home/jenkins# cat /etc/passwd | grep jenkins
jenkins:x:1000:1000:Linux User,,,:/home/jenkins:/bin/bash
306d0b718aef:/home/jenkins# cat /etc/group | grep jenkins
jenkins:x:1000:jenkins
306d0b718aef:/home/jenkins# ls /
bin    dev    etc    home   lib    media  mnt    opt    proc   root   run    sbin   srv    sys    tmp    usr    var
306d0b718aef:/home/jenkins# ls /home/
jenkins
306d0b718aef:/home/jenkins# ls /home/jenkins/
agent
306d0b718aef:/home/jenkins# env
HOSTNAME=306d0b718aef
JAVA_HOME=/opt/java/openjdk
HOME=/root
JENKINS_AGENT_HOME=/home/jenkins
PATH=/opt/java/openjdk/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
AGENT_WORKDIR=/home/jenkins/agent
JAVA_VERSION=jdk-11.0.17+8
_=/usr/bin/env
306d0b718aef:/home/jenkins# ps
PID   USER     TIME  COMMAND
    1 root      0:00 sshd: /usr/sbin/sshd -D -e [listener] 0 of 10-100 startups
   10 root      0:00 /bin/bash
   25 root      0:00 ps
306d0b718aef:/home/jenkins# ls -A
.jenkins  .ssh      agent
306d0b718aef:/home/jenkins#

```
so we have ssh server, with jenkins user

## use docker agent without devoting ssh-agent or jnlp-agent
Actually what I want is to have my docker server/controller run in docker and I can pull any docker-image, fo example from docker-hub, or create a custom one, and use it for my pipleline,
one for all steps, or different docker image for different steps, and I found it her:<br>
[How to Setup Docker Containers As Build Agents for Jenkins](https://www.youtube.com/watch?v=ymI02j-hqpU), and it's github at [here](https://github.com/mc1496/jenkins4-jenkins-example-docker)


