# SDSetup Podman Setup (Local Development)

This guide shows how to run SDSetup locally using Podman instead of Docker.

## Prerequisites

1. **Install Podman:**
   ```bash
   # Fedora/RHEL/CentOS
   sudo dnf install podman podman-compose
   
   # Ubuntu/Debian
   sudo apt-get install podman podman-compose
   
   # macOS
   brew install podman
   ```

2. **Start Podman service (if needed):**
   ```bash
   # Linux
   systemctl --user enable podman.socket
   systemctl --user start podman.socket
   
   # macOS
   podman machine init
   podman machine start
   ```

## Method 1: Using podman-compose (Recommended)

### Quick Start
```bash
# Clone or download the project
cd SDSetup

# Build and run using podman-compose
podman-compose up --build
```

### Detailed Steps

1. **Navigate to your project directory:**
   ```bash
   cd /path/to/SDSetup
   ```

2. **Build and start the services:**
   ```bash
   # Build images and start containers
   podman-compose up --build
   
   # Or run in detached mode
   podman-compose up --build -d
   ```

3. **Access the application:**
   - Frontend: `http://localhost`
   - Backend API: `http://localhost:5000`

4. **View logs:**
   ```bash
   # All services
   podman-compose logs
   
   # Specific service
   podman-compose logs backend
   podman-compose logs frontend
   
   # Follow logs
   podman-compose logs -f
   ```

5. **Stop the services:**
   ```bash
   podman-compose down
   ```

## Method 2: Using individual Podman commands

### Build Images
```bash
# Build backend image
podman build -f Dockerfile.backend -t sdsetup-backend .

# Build frontend image
podman build -f Dockerfile.blazor -t sdsetup-frontend .
```

### Create Network
```bash
podman network create sdsetup-network
```

### Run Containers
```bash
# Backend container
podman run -d \
  --name sdsetup-backend \
  --network sdsetup-network \
  -p 5000:5000 \
  -v sdsetup-config:/app/config \
  -v sdsetup-files:/app/files \
  -v sdsetup-temp:/app/temp \
  -v sdsetup-updater:/app/updater \
  sdsetup-backend

# Frontend container
podman run -d \
  --name sdsetup-frontend \
  --network sdsetup-network \
  -p 80:80 \
  -p 443:443 \
  sdsetup-frontend
```

### Manage Containers
```bash
# List containers
podman ps

# Stop containers
podman stop sdsetup-backend sdsetup-frontend

# Remove containers
podman rm sdsetup-backend sdsetup-frontend

# Remove images
podman rmi sdsetup-backend sdsetup-frontend
```

## Method 3: Using Podman Desktop (GUI)

1. **Install Podman Desktop:**
   - Download from: https://podman-desktop.io/
   - Install and start Podman Desktop

2. **Load the project:**
   - Open Podman Desktop
   - Go to "Containers" → "Create Container"
   - Or use "Pods" → "Create Pod"

3. **Use the docker-compose.yml:**
   - Podman Desktop can read docker-compose files
   - Import the project and use the compose file

## Development Workflow

### Making Changes
```bash
# Stop services
podman-compose down

# Make your code changes

# Rebuild and restart
podman-compose up --build
```

### Debugging
```bash
# Run in interactive mode
podman-compose run --rm backend bash

# Check container logs
podman logs sdsetup-backend

# Execute commands in running container
podman exec -it sdsetup-backend bash
```

### Volume Management
```bash
# List volumes
podman volume ls

# Inspect volume
podman volume inspect sdsetup-backend-config

# Remove volumes (careful - this deletes data)
podman volume rm sdsetup-backend-config
```

## Podman-Specific Considerations

### Rootless Mode
Podman runs rootless by default, which is more secure:
```bash
# Check if running rootless
podman info | grep rootless

# If you need root mode (not recommended)
sudo podman-compose up --build
```

### SELinux (RHEL/Fedora)
If you encounter permission issues:
```bash
# Check SELinux status
getenforce

# If enforcing, you might need to adjust contexts
# or run with --privileged (not recommended for production)
```

### Port Conflicts
If ports are already in use:
```bash
# Check what's using the ports
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :5000

# Or modify docker-compose.yml to use different ports
```

## Troubleshooting

### Common Issues

1. **Permission denied:**
   ```bash
   # Check if running rootless
   podman info | grep rootless
   
   # If needed, adjust file permissions
   chmod 755 .
   ```

2. **Port already in use:**
   ```bash
   # Find what's using the port
   sudo lsof -i :80
   sudo lsof -i :5000
   
   # Kill the process or change ports in docker-compose.yml
   ```

3. **Build failures:**
   ```bash
   # Clean up and rebuild
   podman-compose down
   podman system prune -a
   podman-compose up --build
   ```

4. **Network issues:**
   ```bash
   # Check networks
   podman network ls
   
   # Remove and recreate network
   podman network rm sdsetup-network
   podman network create sdsetup-network
   ```

### Performance Tips

1. **Use BuildKit (if available):**
   ```bash
   export DOCKER_BUILDKIT=1
   podman-compose up --build
   ```

2. **Mount source code for development:**
   ```bash
   # Add to docker-compose.yml for development
   volumes:
     - ./SDSetupBackend:/app/src
   ```

3. **Use podman-compose with caching:**
   ```bash
   # Build with cache
   podman-compose build --no-cache
   ```

## Cleanup

```bash
# Stop and remove everything
podman-compose down -v

# Remove all unused resources
podman system prune -a

# Remove specific images
podman rmi sdsetup-backend sdsetup-frontend
```

## Next Steps

Once running locally, you can:
1. Access the web interface at `http://localhost`
2. Test API endpoints at `http://localhost:5000`
3. Make code changes and rebuild
4. Deploy to production using the same configuration 