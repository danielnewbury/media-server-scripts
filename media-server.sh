#!/bin/bash
# media-server.sh - Local script to manage remote media server
# Usage: ./media-server.sh [start|stop|restart|status]

SERVER="192.168.1.177"
USER="daniel"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Remote script that will be executed on the server
read -r -d '' REMOTE_SCRIPT << 'EOF'
#!/bin/bash
set -e
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
DOCKER_BASE="docker/media-server"

start_services() {
    echo -e "${BLUE}Starting Media Server Services...${NC}\n"
    
    echo -e "${GREEN}Starting Audiobookshelf...${NC}"
    docker-compose -f ${DOCKER_BASE}/audiobookshelf/docker-compose.yml up -d
    
    echo -e "${GREEN}Starting Gluetun VPN and qBittorrent...${NC}"
    docker-compose -f ${DOCKER_BASE}/downloaders/docker-compose.yml up -d gluetun qbittorrent
    
    echo -e "${GREEN}Starting Finders (Readarr, Lidarr, Radarr, Sonarr)...${NC}"
    docker-compose -f ${DOCKER_BASE}/finders/docker-compose.yml up -d
    
    echo -e "${GREEN}Starting Plex and Tautulli...${NC}"
    docker-compose -f ${DOCKER_BASE}/players/docker-compose.yml up -d plex tautulli
    
    echo -e "\n${BLUE}All services started successfully!${NC}"
}

stop_services() {
    echo -e "${YELLOW}Stopping Media Server Services...${NC}\n"
    
    echo -e "${YELLOW}Stopping Plex and Tautulli...${NC}"
    docker-compose -f ${DOCKER_BASE}/players/docker-compose.yml stop plex tautulli
    
    echo -e "${YELLOW}Stopping Finders...${NC}"
    docker-compose -f ${DOCKER_BASE}/finders/docker-compose.yml stop
    
    echo -e "${YELLOW}Stopping Downloaders...${NC}"
    docker-compose -f ${DOCKER_BASE}/downloaders/docker-compose.yml stop gluetun qbittorrent
    
    echo -e "${YELLOW}Stopping Audiobookshelf...${NC}"
    docker-compose -f ${DOCKER_BASE}/audiobookshelf/docker-compose.yml stop
    
    echo -e "\n${BLUE}All services stopped!${NC}"
}

down_services() {
    echo -e "${RED}Tearing down Media Server Services (removing containers & networks)...${NC}\n"
    
    echo -e "${RED}Removing Players...${NC}"
    docker-compose -f ${DOCKER_BASE}/players/docker-compose.yml down
    
    echo -e "${RED}Removing Finders...${NC}"
    docker-compose -f ${DOCKER_BASE}/finders/docker-compose.yml down
    
    echo -e "${RED}Removing Downloaders...${NC}"
    docker-compose -f ${DOCKER_BASE}/downloaders/docker-compose.yml down
    
    echo -e "${RED}Removing Audiobookshelf...${NC}"
    docker-compose -f ${DOCKER_BASE}/audiobookshelf/docker-compose.yml down
    
    echo -e "\n${BLUE}All services removed!${NC}"
}

status_services() {
    echo -e "${BLUE}Media Server Status:${NC}\n"
    
    echo -e "${GREEN}Audiobookshelf:${NC}"
    docker-compose -f ${DOCKER_BASE}/audiobookshelf/docker-compose.yml ps
    
    echo -e "\n${GREEN}Downloaders:${NC}"
    docker-compose -f ${DOCKER_BASE}/downloaders/docker-compose.yml ps
    
    echo -e "\n${GREEN}Finders:${NC}"
    docker-compose -f ${DOCKER_BASE}/finders/docker-compose.yml ps
    
    echo -e "\n${GREEN}Players:${NC}"
    docker-compose -f ${DOCKER_BASE}/players/docker-compose.yml ps
}

case "$1" in
    start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    down)
        down_services
        ;;
    up)
        start_services
        ;;
    restart)
        stop_services
        sleep 2
        start_services
        ;;
    status)
        status_services
        ;;
    *)
        echo "Usage: $0 {start|stop|down|up|restart|status}"
        exit 1
        ;;
esac
EOF

# Main script logic
case "$1" in
    start|up)
        echo -e "${BLUE}Connecting to ${SERVER} and starting services...${NC}\n"
        ssh ${USER}@${SERVER} "bash -s start" <<< "$REMOTE_SCRIPT"
        ;;
    stop)
        echo -e "${YELLOW}Connecting to ${SERVER} and stopping services...${NC}\n"
        ssh ${USER}@${SERVER} "bash -s stop" <<< "$REMOTE_SCRIPT"
        ;;
    down)
        echo -e "${RED}Connecting to ${SERVER} and tearing down services...${NC}\n"
        ssh ${USER}@${SERVER} "bash -s down" <<< "$REMOTE_SCRIPT"
        ;;
    restart)
        echo -e "${BLUE}Connecting to ${SERVER} and restarting services...${NC}\n"
        ssh ${USER}@${SERVER} "bash -s restart" <<< "$REMOTE_SCRIPT"
        ;;
    status)
        echo -e "${BLUE}Connecting to ${SERVER} and checking status...${NC}\n"
        ssh ${USER}@${SERVER} "bash -s status" <<< "$REMOTE_SCRIPT"
        ;;
    *)
        echo -e "${RED}Usage: $0 {start|up|stop|down|restart|status}${NC}"
        echo ""
        echo "Commands:"
        echo "  start/up - Start all media server services"
        echo "  stop     - Stop all services (containers remain)"
        echo "  down     - Stop and remove all containers and networks"
        echo "  restart  - Restart all media server services"
        echo "  status   - Check status of all services"
        exit 1
        ;;
esac