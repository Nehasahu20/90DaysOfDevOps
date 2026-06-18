## Day 30 — Docker Images & Container Lifecycle

### Images

```bash
docker pull nginx
docker pull ubuntu
docker pull alpine

docker images
# nginx   ~190MB
# ubuntu  ~70MB
# alpine  ~7MB  ← smallest!

docker image history nginx      # view layers
docker image inspect nginx      # detailed info
docker rmi alpine               # remove image
```

### Full Lifecycle

```bash
docker create --name lc nginx   # Created
docker start lc                 # Up
docker pause lc                 # Paused
docker unpause lc               # Up
docker stop lc                  # Exited (0)
docker restart lc               # Up
docker kill lc                  # Exited (137)
docker rm lc                    # Gone
```

### Exit Codes

| Code | Meaning |
|---|---|
| 0 | Normal exit |
| 1 | App error |
| 127 | Command not found |
| 137 | Force killed |

### Cleanup

```bash
docker stop $(docker ps -q)       # stop all
docker rm $(docker ps -aq)        # remove all stopped
docker image prune -a             # remove unused images
docker system prune -a            # full cleanup
docker system df                  # disk usage
```

---
