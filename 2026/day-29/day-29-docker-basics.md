## Day 29 — Introduction to Docker

### Install Docker (Amazon Linux 2023)

```bash
sudo dnf install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
newgrp docker
docker --version
```

### Key Commands

```bash
# Run containers
docker run hello-world
docker run -d --name my-nginx -p 8080:80 nginx
docker run -it --name my-ubuntu ubuntu bash

# Inside container
root@container:/# cat /etc/os-release
root@container:/# exit

# Manage containers
docker ps              # running only
docker ps -a           # all containers
docker stop my-nginx
docker rm my-nginx
docker logs my-nginx
docker logs -f my-nginx           # follow live
docker exec -it my-nginx bash     # enter running container
docker exec my-nginx nginx -v     # run one command

# Detach without stopping
# Press Ctrl+P then Ctrl+Q
docker attach <name>              # re-attach
docker start -ai <name>           # re-enter exited container
```

### Container vs Host Prompt

| Prompt | Location |
|---|---|
| `root@containerID:/#` | Inside Docker container |
| `[ec2-user@ip-172-31 ~]$` | EC2 host machine |

