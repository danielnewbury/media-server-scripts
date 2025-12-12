# Media Server Management Script

A convenient bash script to remotely manage your media server's Docker Compose services from your local machine.

## Overview

This script automates the management of a media server stack running on a remote Ubuntu server (192.168.1.177). It handles starting, stopping, and monitoring multiple Docker Compose services including:

- **Audiobookshelf** - Audiobook and podcast server
- **Downloaders** - Gluetun VPN and qBittorrent
- **Finders** - Readarr, Lidarr, Radarr, Sonarr (the *arr stack)
- **Players** - Plex Media Server and Tautulli

## Prerequisites

- SSH access to the remote media server (192.168.1.177)
- Docker and Docker Compose installed on the remote server
- Bash shell on your local machine

## Installation

1. Download the script to your local machine:
```bash
wget https://your-repo/media-server.sh
# or
curl -O https://your-repo/media-server.sh
```

2. Make the script executable:
```bash
chmod +x media-server.sh
```

3. (Optional but recommended) Set up SSH key authentication to avoid password prompts:
```bash
ssh-copy-id daniel@192.168.1.177
```

## Usage

```bash
./media-server.sh [command]
```

### Available Commands

| Command | Description |
|---------|-------------|
| `start` or `up` | Start all media server services |
| `stop` | Stop all services (containers remain for quick restart) |
| `down` | Stop and remove all containers and networks (full teardown) |
| `restart` | Stop and start all services |
| `status` | Check the status of all services |

### Examples

Start all services:
```bash
./media-server.sh start
```

Stop services without removing containers:
```bash
./media-server.sh stop
```

Completely tear down the stack:
```bash
./media-server.sh down
```

Check what's running:
```bash
./media-server.sh status
```

## How It Works

The script connects to your media server via SSH and executes Docker Compose commands in the correct order:

**Startup Order:**
1. Audiobookshelf
2. Gluetun VPN → qBittorrent
3. All Finders (Readarr, Lidarr, Radarr, Sonarr)
4. Plex and Tautulli

**Shutdown Order:**
1. Plex and Tautulli
2. All Finders
3. Downloaders
4. Audiobookshelf

## Configuration

To customize the script for your setup, edit these variables at the top of the script:

```bash
SERVER="192.168.1.177"  # Your media server IP
USER="daniel"            # Your SSH username
```

The script assumes your Docker Compose files are organized as:
```
~/docker/media-server/
├── audiobookshelf/docker-compose.yml
├── downloaders/docker-compose.yml
├── finders/docker-compose.yml
└── players/docker-compose.yml
```

If your directory structure differs, update the `DOCKER_BASE` variable in the remote script section.

## Troubleshooting

### Network Removal Errors

If you see errors about networks having active endpoints (e.g., `docker_socket_proxy`, `watchtower`), use `stop` instead of `down`:

```bash
./media-server.sh stop  # Stops containers without removing networks
```

Only use `down` when you want a complete teardown and are sure no other containers are using the networks.

### SSH Connection Issues

If you're prompted for a password every time:
```bash
ssh-copy-id daniel@192.168.1.177
```

If SSH hangs or times out, check your network connection and firewall settings.

### Permission Errors

Ensure your user has permission to run Docker commands without sudo:
```bash
sudo usermod -aG docker daniel
```
Then log out and back in for the changes to take effect.

## License

MIT

## Contributing

Feel free to submit issues or pull requests if you have suggestions for improvements!