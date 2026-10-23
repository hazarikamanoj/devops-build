# DevOps Project 3: React E-Commerce App, Docker + Jenkins CI/CD on AWS

A pre-built React e-commerce application ("OnlineShop") packaged with Docker, built and deployed automatically by Jenkins on every push, and monitored with Uptime Kuma.

## Submission details

| Item | Value |
|---|---|
| GitHub repo | https://github.com/hazarikamanoj/devops-build |
| Deployed site | http://98.95.127.41 |
| Docker image (dev, public) | `manojkudocker/dev` |
| Docker image (prod, private) | `manojkudocker/prod` |
| Jenkins | http://98.95.127.41:8080 (login required) |
| Monitoring | Uptime Kuma on port 3001 (restricted access) |
| Source application | https://github.com/sriram-R-krishnan/devops-build (pre-built `build/` folder) |

## How it works

```
 git push (dev)  ──┐
                   ├─> GitHub webhook ─> Jenkins (Multibranch Pipeline, on EC2)
 git merge master ─┘                          │
                                              ├─ Build  : ./build.sh  (docker build)
                                              ├─ Push   : Docker Hub  (dev repo or prod repo)
                                              └─ Deploy : ./deploy.sh (docker compose on the same EC2 host, port 80)

 Uptime Kuma ──(HTTP check every 60 s)──> http://98.95.127.41 ──> Telegram alert when DOWN
```

- Push to `dev`: the image is built and pushed to `manojkudocker/dev`, then deployed.
- Merge `dev` into `master`: the image is built and pushed to `manojkudocker/prod`, then deployed.
- Images are tagged with the Jenkins build number and `latest`.

## Repository contents

| File | Purpose |
|---|---|
| `build/` | Pre-built React application |
| `Dockerfile` | `nginx:alpine` image serving `build/` on port 80 |
| `nginx.conf` | Serves the single-page app (falls back to `index.html`) |
| `docker-compose.yml` | Runs the image on port 80 (`IMAGE` and `TAG` come from the environment) |
| `build.sh` | Builds and tags the Docker image |
| `deploy.sh` | Pulls the image and starts it with Docker Compose |
| `Jenkinsfile` | Build, Push and Deploy stages; picks the dev or prod repo by branch |
| `.dockerignore`, `.gitignore` | Keep the image and the repo clean |

## Infrastructure

- **AWS EC2:** `t3.small`, Ubuntu 24.04, region `us-east-1`, with an Elastic IP. The `t2.micro` type from the assignment was not available in this region for the account, so the equivalent `t3.small` was used.
- **Security group:**

| Port | Source | Reason |
|---|---|---|
| 22 (SSH) | Administrator's IP only | Server login |
| 80 (HTTP) | Anywhere | Public access to the application |
| 8080 | Anywhere | Jenkins UI and GitHub webhook (login required) |
| 3001 | Administrator's IP range only | Uptime Kuma |

- **Docker Hub:** `dev` (public) and `prod` (private) repositories. Jenkins authenticates with an access token stored as a Jenkins credential (`dockerhub-creds`), never in the repo.
- **Jenkins:** Multibranch Pipeline `devops-build-pipeline`, GitHub branch source with the `github-token` credential, and a GitHub webhook (`/github-webhook/`) for automatic builds on both `dev` and `master`.
- **Monitoring:** Uptime Kuma (Docker) with an HTTP monitor on the site, checked every 60 seconds. A Telegram bot sends a message when the application goes down, and another when it recovers.

## Screenshots

All screenshots are in the [`screenshots/`](screenshots/) folder.

### Version control
![Git CLI](screenshots/24-git-cli-log.png)

### Bash scripts
**build.sh** run locally (`./build.sh manojkudocker/dev test`): builds the image and tags it with the given tag and `latest`

![build.sh](screenshots/25-script-build-sh.png)

**deploy.sh** (pulls the image and starts it with Docker Compose)

![deploy.sh](screenshots/26-script-deploy-sh.png)

### Jenkins
**Login page**

![Jenkins login](screenshots/01-jenkins-login.png)

**Credentials** (secrets masked)

![Jenkins credentials](screenshots/02-jenkins-credentials.png)

**Configuration settings**

![Branch sources](screenshots/03-jenkins-config-branch-sources.png)
![Build configuration and triggers](screenshots/04-jenkins-config-triggers.png)

**Branches and Jenkinsfile steps**

![Dashboard with dev and master](screenshots/05-jenkins-dashboard-branches.png)
![Jenkinsfile pipeline steps](screenshots/06-jenkins-jenkinsfile-pipeline-steps.png)

**Execute step commands: `dev` build** (checkout, `./build.sh`, `docker push`, `./deploy.sh`, success)

![dev console 1](screenshots/07-jenkins-console-dev-1.png)
![dev console 2](screenshots/07-jenkins-console-dev-2.png)
![dev console 3](screenshots/07-jenkins-console-dev-3.png)
![dev console 4](screenshots/07-jenkins-console-dev-4.png)
![dev console 5](screenshots/07-jenkins-console-dev-5.png)

**Execute step commands: `master` build** (pushes to the prod repo)

![master console 1](screenshots/08-jenkins-console-master-1.png)
![master console 2](screenshots/08-jenkins-console-master-2.png)
![master console 3](screenshots/08-jenkins-console-master-3.png)
![master console 4](screenshots/08-jenkins-console-master-4.png)
![master console 5](screenshots/08-jenkins-console-master-5.png)

### Automatic build trigger
![GitHub webhook](screenshots/09-github-webhook-settings.png)
![Webhook deliveries 1](screenshots/10-github-webhook-deliveries-1.png)
![Webhook deliveries 2](screenshots/10-github-webhook-deliveries-2.png)
![Jenkins webhook events 1](screenshots/11-jenkins-webhook-events-1.png)
![Jenkins webhook events 2](screenshots/11-jenkins-webhook-events-2.png)

### Docker Hub
**Access token used by Jenkins** (scope: repo read, write, delete; the token value itself is never shown)

![Docker Hub token settings](screenshots/27-dockerhub-token-settings.png)

**Repositories and tags**

![Repositories](screenshots/12-dockerhub-repos.png)
![dev tags](screenshots/13-dockerhub-dev-tags.png)
![prod tags 1](screenshots/14-dockerhub-prod-tags-1.png)
![prod tags 2](screenshots/14-dockerhub-prod-tags-2.png)

### AWS
![EC2 console](screenshots/15-aws-ec2-console.png)
![Security group configuration](screenshots/16-aws-security-group.png)
![Containers on the server](screenshots/18-server-docker-ps.png)

### Deployed site
![Deployed site](screenshots/17-deployed-site.png)

### Monitoring health check status
**Notification setup**

![Telegram notification setup](screenshots/19-monitoring-notification-config.png)

**Application stopped (`docker stop react-app`): DOWN alert**

![Dashboard down](screenshots/20-monitoring-down-dashboard.png)
![Telegram down](screenshots/21-monitoring-down-telegram.png)

**Application restarted (`docker start react-app`): recovery**

![Dashboard up](screenshots/22-monitoring-up-dashboard.png)
![Telegram up](screenshots/23-monitoring-up-telegram.png)

## Notes

- Both branches deploy to the same EC2 host on port 80, so the version currently live is whichever build ran last.
- Uptime Kuma sends a recovery message when the app comes back, in addition to the DOWN alert.
- The Jenkins UI is served over plain HTTP, which is acceptable for this short-lived project. For anything long-lived, put it behind HTTPS and restrict the source IPs.
- No credentials are stored in this repository. Docker Hub and GitHub tokens live in the Jenkins credential store.
