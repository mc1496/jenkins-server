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
