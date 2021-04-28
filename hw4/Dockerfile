FROM ubuntu:18.04
RUN apt-get update
RUN apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update
RUN apt-get -y install docker-ce docker-ce-cli containerd.io

RUN usermod -aG docker $(whoami)
RUN newgrp docker
RUN touch dk.sh; echo "service docker start" >> dk.sh; echo "docker run hello-world" >> dk.sh; echo "/bin/bash" >> dk.sh
RUN chmod +x dk.sh;
CMD ["/bin/sh", "dk.sh"]
