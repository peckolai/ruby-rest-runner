# Docker Usage Guide

This guide explains how to use ruby-rest-runner in a Docker container.

## Quick Start

### Build the Docker Image

```bash
docker build -t ruby-rest-runner:latest .
```

### Run Commands

#### Help
```bash
docker run --rm ruby-rest-runner:latest --help
```

#### Execute a Collection
```bash
docker run --rm \
  -v $(pwd)/collections:/app/collections:ro \
  ruby-rest-runner:latest \
  exec collections/jsonplaceholder_demo.yml
```

#### List Collections
```bash
docker run --rm \
  -v $(pwd)/collections:/app/collections:ro \
  ruby-rest-runner:latest \
  list
```

## Using Docker Compose

### Build and Run
```bash
docker-compose up --build
```

### Execute a Collection
```bash
docker-compose run --rm rest-runner exec collections/jsonplaceholder_demo.yml
```

### Interactive Mode

Uncomment the following in `docker-compose.yml`:
```yaml
stdin_open: true
tty: true
```

Then:
```bash
docker-compose run --rm rest-runner
```

## Volume Mounting

Mount your local directories to the container:

```bash
docker run --rm \
  -v $(pwd)/collections:/app/collections:ro \
  -v $(pwd)/config/envs:/app/config/envs:ro \
  -v $(pwd)/results:/app/results \
  ruby-rest-runner:latest \
  exec collections/demo.yml
```

**Mount Paths:**
- `/app/collections` - Your test collections (read-only)
- `/app/config/envs` - Your environment configurations
- `/app/results` - Output results directory

## Environment Variables

Pass environment variables to the container:

```bash
docker run --rm \
  -e BASE_URL="https://api.example.com" \
  -e API_TOKEN="secret-token" \
  -v $(pwd)/collections:/app/collections:ro \
  ruby-rest-runner:latest \
  exec collections/demo.yml
```

## Production Deployment

### Image Size
- Final image: ~200MB (Ruby 3.4 slim + dependencies)
- Multi-stage build ensures minimal bloat

### Security
- Non-root user (UID 1000) runs the container
- No build tools in final image
- Minimal attack surface with slim base image

### Example Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rest-runner
spec:
  replicas: 1
  selector:
    matchLabels:
      app: rest-runner
  template:
    metadata:
      labels:
        app: rest-runner
    spec:
      containers:
      - name: rest-runner
        image: ruby-rest-runner:latest
        volumeMounts:
        - name: collections
          mountPath: /app/collections
          readOnly: true
        - name: config
          mountPath: /app/config/envs
          readOnly: true
        env:
        - name: BASE_URL
          valueFrom:
            configMapKeyRef:
              name: rest-runner-config
              key: base_url
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
      volumes:
      - name: collections
        configMap:
          name: rest-runner-collections
      - name: config
        configMap:
          name: rest-runner-config
```

## Troubleshooting

### Permission Denied
Ensure your collections directory is readable:
```bash
chmod -R 755 collections/
```

### Out of Memory
Increase Docker memory limit or use resource constraints:
```bash
docker run --memory=1g ...
```

### DNS Resolution
If containers can't reach external APIs:
```bash
docker run --dns 8.8.8.8 ...
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Rest Runner Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build Docker image
        run: docker build -t ruby-rest-runner:latest .
      
      - name: Run collections
        run: |
          docker run --rm \
            -v $(pwd)/collections:/app/collections:ro \
            ruby-rest-runner:latest \
            exec collections/demo.yml
```

### GitLab CI Example

```yaml
test:
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t ruby-rest-runner:latest .
    - docker run --rm -v $(pwd)/collections:/app/collections:ro ruby-rest-runner:latest exec collections/demo.yml
```

## Performance Tips

1. **Layer Caching**: Modify only application code to leverage Docker layer caching
2. **Multi-Stage Build**: Already implemented to reduce final image size
3. **Volume Performance**: Use `:ro` (read-only) flags for better performance
4. **Resource Limits**: Set appropriate memory/CPU limits for your environment

## Building for Different Architectures

Build for ARM64 (Apple Silicon):
```bash
docker buildx build --platform linux/arm64 -t ruby-rest-runner:latest .
```

Build for multiple architectures:
```bash
docker buildx build --platform linux/amd64,linux/arm64 -t ruby-rest-runner:latest .
```

## Pushing to Registry

### Docker Hub
```bash
docker tag ruby-rest-runner:latest yourusername/ruby-rest-runner:latest
docker push yourusername/ruby-rest-runner:latest
```

### Private Registry
```bash
docker tag ruby-rest-runner:latest registry.example.com/ruby-rest-runner:latest
docker push registry.example.com/ruby-rest-runner:latest
```
