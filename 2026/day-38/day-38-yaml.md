# Day 38 – YAML Basics

## What is YAML and Why Learn It?

YAML = **YAML Ain't Markup Language**

Almost every DevOps tool uses YAML:

- Docker Compose → `docker-compose.yml`
- GitHub Actions → `.github/workflows/*.yml`
- Kubernetes → Deployment, Service, ConfigMap files
- Ansible → Playbooks
- Helm → `values.yaml`

Master YAML once → use it everywhere.

---

## Useful Docker & Compose Commands

### Docker Compose

```bash
docker compose build                    # build all images
docker compose build --no-cache web     # rebuild without cache
docker compose pull                     # pull latest images
docker compose exec web bash            # shell into running service
docker compose run --rm web pytest      # run one-off command
docker compose config                   # validate + show resolved YAML
docker compose restart web              # restart specific service
```

### Docker Cleanup

```bash
docker system df                        # show disk usage summary
docker system df -v                     # detailed breakdown

# Remove unused resources
docker system prune                     # stopped containers + unused networks + dangling images
docker system prune -a                  # includes unused images
docker system prune -a --volumes        # EVERYTHING including volumes ⚠ DATA LOSS

# Individual cleanup
docker container prune                  # remove stopped containers
docker image prune                      # remove dangling images
docker image prune -a                   # remove all unused images
docker volume prune                     # remove unused volumes
docker network prune                    # remove unused networks
```

---

# Golden Rule

## SPACES ONLY — NEVER TABS

✅ Correct

```yaml
name: Neha
role: DevOps
```

❌ Wrong

```yaml
name: Neha
	role: DevOps
```

Error:

```text
found character '\t' that cannot start any token
```

---

# Task 1 – Key-Value Pairs & Data Types

## Basic Key-Value

```yaml
name: Neha Sahu
role: DevOps Engineer
experience_years: 2
learning: true
```

---

## Strings

```yaml
city: Mumbai

message: "port: 8080"
greeting: 'Hello World'
```

Use quotes when values contain special characters:

```text
: # & * ! | > '
```

---

## Numbers

```yaml
port: 8080
version: 1.25
big_number: 1_000_000
```

---

## Booleans

```yaml
active: true
debug: false

enabled: yes
disabled: no

feature_on: on
feature_off: off
```

### Important

```yaml
active: true
```

→ Boolean

```yaml
active: "true"
```

→ String

---

## Null Values

```yaml
value: ~

value: null
```

---

## Dates

```yaml
created: 2026-06-13
```

---

## Syntax Rule

✅ Correct

```yaml
name: Neha
```

❌ Wrong

```yaml
name:Neha
```

A space after `:` is mandatory.

---

# Task 2 – Lists

## Block Style (Recommended)

```yaml
tools:
  - Docker
  - Kubernetes
  - Ansible
  - Terraform
  - Jenkins
```

Best for long lists.

---

## Inline Style

```yaml
hobbies: [coding, reading, hiking]
```

Best for short lists.

---

## Nested Lists

```yaml
matrix:
  - [1, 2, 3]
  - [4, 5, 6]
```

---

# Task 3 – Nested Objects

## Two Levels

```yaml
server:
  name: web-server-01
  ip: 192.168.1.100
  port: 8080
```

---

## Three Levels

```yaml
database:
  host: db.internal
  name: myapp_db

  credentials:
    user: dbadmin
    password: secret123
```

---

## Common Indentation Error

❌ Wrong

```yaml
server:
  name: web-server-01
	ip: 192.168.1.100
```

Error:

```text
found character '\t' that cannot start any token
```

---

# Task 4 – Multi-Line Strings

## Literal Block (`|`)

Preserves line breaks exactly.

```yaml
startup_script: |
  #!/bin/bash
  echo "Starting server..."
  systemctl start nginx
  systemctl start docker
  echo "Done!"
```

Result:

```text
#!/bin/bash
echo "Starting server..."
systemctl start nginx
systemctl start docker
echo "Done!"
```

Use for:

- Shell scripts
- SQL queries
- Code snippets

---

## Folded Block (`>`)

Converts line breaks into spaces.

```yaml
description: >
  This server runs the main
  web application and handles
  all incoming traffic from users.
```

Result:

```text
This server runs the main web application and handles all incoming traffic from users.
```

Use for:

- Long descriptions
- Notes
- Documentation

---

## Comparison

| Style | Symbol | Preserves Newlines? | Best For |
|---------|---------|---------|---------|
| Literal | `|` | Yes | Scripts, code, SQL |
| Folded | `>` | No | Descriptions, notes |

---

# Task 5 – Validate YAML

## Install yamllint

```bash
pip3 install yamllint
```

---

## Validate One File

```bash
yamllint person.yaml
```

Valid output:

```text
(no output)
```

Invalid output:

```text
person.yaml:3:1: error: wrong indentation
```

---

## Validate Multiple Files

```bash
yamllint *.yaml
```

---

## Example Error

```text
3:1: error: found character '\t' that cannot start any token
```

Fix indentation and rerun.

---

## Validate with Python

```bash
python3 -c "
import yaml

with open('person.yaml') as f:
    data = yaml.safe_load(f)

print('Valid YAML!')
print(data)
" && echo "Valid" || echo "Invalid"
```

---

# Task 6 – Spot the Bug

## Correct List

```yaml
name: devops

tools:
  - docker
  - kubernetes
```

---

## Broken List

```yaml
name: devops

tools:- docker
  - kubernetes
```

Error:

```text
mapping values are not allowed here
```

---

# Anchors & Aliases (DRY)

Useful in:

- GitLab CI
- Docker Compose
- Kubernetes Helm

---

## Define Anchor

```yaml
defaults: &defaults
  image: python:3.11-slim
  restart: always

  networks:
    - backend
```

---

## Reuse Anchor

```yaml
web:
  <<: *defaults

  ports:
    - "5000:5000"
```

Effective result:

```yaml
web:
  image: python:3.11-slim
  restart: always

  networks:
    - backend

  ports:
    - "5000:5000"
```

---

## Another Reuse

```yaml
worker:
  <<: *defaults

  command: python worker.py
```

Effective result:

```yaml
worker:
  image: python:3.11-slim
  restart: always

  networks:
    - backend

  command: python worker.py
```

---

# List of Objects (Most Important Pattern)

Used everywhere in:

- Kubernetes
- Docker Compose
- Helm
- Ansible

Example:

```yaml
servers:
  - name: web-01
    ip: 10.0.0.1
    tags: [web, prod]

  - name: db-01
    ip: 10.0.0.2
    tags: [db, prod]
```

---

## Kubernetes Example

```yaml
env:
  - name: DB_HOST
    value: localhost

  - name: DB_PORT
    value: "5432"
```

Note:

```yaml
value: "5432"
```

is quoted so it remains a string.

---

# Common YAML Mistakes Reference

| Mistake | Wrong | Correct | Error |
|----------|----------|----------|----------|
| Tab indent | `\tname: val` | `name: val` | cannot start token |
| No space after colon | `name:val` | `name: val` | mapping error |
| Unquoted colon in value | `url: http://x:8080` | `url: "http://x:8080"` | mapping error |
| Wrong boolean case | `active: True` | `active: true` | treated as string |
| Duplicate keys | two `name:` keys | one key only | second silently overwrites first |
| Wrong list indent | dash at wrong level | proper indentation | invalid structure |

---

# Day 38 Summary

You learned:

- YAML syntax fundamentals
- Data types
- Lists
- Nested objects
- Multi-line strings (`|` and `>`)
- Validation using `yamllint`
- Anchors & aliases (`&` and `*`)
- List-of-objects pattern
- Common YAML mistakes

**Next step:** Kubernetes manifests become much easier because they are simply large YAML files using these exact patterns.
