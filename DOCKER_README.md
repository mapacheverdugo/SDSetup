# SDSetup Docker Setup

This repository contains Docker configuration for running SDSetup in Portainer or any Docker environment.

## Architecture

The application consists of two main services:

1. **Backend** (.NET Core 2.2): API server running on port 5000
2. **Frontend** (.NET 6.0 Blazor WebAssembly): Web interface served by nginx on port 80

**Note**: The project uses mixed .NET versions:
- Backend: .NET Core 2.2 (EOL - consider upgrading)
- Frontend: .NET 6.0 with RC packages
- Updater: .NET Core 3.0
- Common: .NET Standard 2.0

## Running in Portainer

### Method 1: Using docker-compose (Recommended)

1. **Upload the files** to your server:
   - `docker-compose.yml`
   - `Dockerfile.backend`
   - `Dockerfile.blazor`
   - `nginx.conf`
   - `.dockerignore`
   - The entire source code

2. **In Portainer:**
   - Go to "Stacks" → "Add stack"
   - Choose "Upload" and select the `docker-compose.yml` file
   - Or choose "Web editor" and paste the contents of `docker-compose.yml`
   - Give your stack a name (e.g., "sdsetup")
   - Click "Deploy the stack"

3. **Access the application:**
   - Frontend: `http://your-server-ip`
   - Backend API: `http://your-server-ip:5000`

### Method 2: Using individual containers

1. **Build the images:**
   ```bash
   docker build -f Dockerfile.backend -t sdsetup-backend .
   docker build -f Dockerfile.blazor -t sdsetup-frontend .
   ```

2. **Create the network:**
   ```bash
   docker network create sdsetup-network
   ```

3. **Run the containers:**
   ```bash
   # Backend
   docker run -d \
     --name sdsetup-backend \
     --network sdsetup-network \
     -p 5000:5000 \
     -v sdsetup-config:/app/config \
     -v sdsetup-files:/app/files \
     -v sdsetup-temp:/app/temp \
     -v sdsetup-updater:/app/updater \
     sdsetup-backend

   # Frontend
   docker run -d \
     --name sdsetup-frontend \
     --network sdsetup-network \
     -p 80:80 \
     -p 443:443 \
     sdsetup-frontend
   ```

## Configuration

### Backend Configuration

The backend configuration is stored in Docker volumes:
- `backend-config`: Configuration files
- `backend-files`: Package files and manifests
- `backend-temp`: Temporary files
- `backend-updater`: Updater files

### Default Configuration

The backend will create default configuration files:
- `host.txt`: `0.0.0.0:5000`
- `latestpackageset.txt`: `default`
- `latestappversion.txt`: `NO VERSION`
- `validchannels.txt`: `latest`, `nightly`

## Troubleshooting

### Common Issues

1. **Port conflicts**: Make sure ports 80 and 5000 are available
2. **Permission issues**: The containers run as non-root users
3. **Build failures**: Ensure you have the complete source code

### Logs

View logs in Portainer:
- Go to "Containers" → Select container → "Logs"

Or via command line:
```bash
docker logs sdsetup-backend
docker logs sdsetup-frontend
```

### Updating

To update the application:
1. Pull the latest code
2. Rebuild the images
3. Restart the stack in Portainer

## Security Notes

- The backend runs on .NET Core 2.2 (EOL)
- Consider using a reverse proxy (nginx, traefik) for production
- The application is configured for development by default
- Review and update security settings for production use

## Version Compatibility

- Backend: .NET Core 2.2 (EOL - consider upgrading)
- Frontend: .NET 6.0 with RC packages
- Updater: .NET Core 3.0
- Common: .NET Standard 2.0
- Docker: 20.10+ recommended
- Portainer: 2.0+ recommended 