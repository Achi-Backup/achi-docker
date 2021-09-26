# Prerequisites

1. Download and install [Docker](https://www.docker.com/get-started) for your OS
2. Install [GIT](https://git-scm.com/)

# Setup

1. Clone repository: `git clone https://github.com/friend-of-achi/achi-docker.git`
2. Enter the directory: `cd achi-docker`
3. Copy `docker-compose.yaml.dist` to `docker-compose.yaml` and edit according to your needs
4. Build container: `docker-compose -f docker-compose.yaml build`
5. Start container: `docker-compose -f docker-compose.yaml up -d`
6. Enter container: `docker exec -it achi bash`
7. Activate achi: `. ./activate`
8. Do whatever you want