# Overleaf Community Edition - Deployment Guide

This guide will help you deploy Overleaf Community Edition to production and make it accessible via a public URL.

## 📋 Prerequisites

Before you begin, ensure you have:

- [Docker](https://www.docker.com/get-started) installed
- [Docker Compose](https://docs.docker.com/compose/install/) installed
- A domain name (for public access)
- Basic knowledge of DNS configuration
- A server with at least 4GB RAM and 20GB storage

## 🚀 Quick Start

### 1. Clone and Setup

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/overleaf-main.git
cd overleaf-main

# Copy environment configuration
cp env.example .env

# Edit the .env file with your configuration
nano .env  # or use your preferred editor
```

### 2. Configure Environment

Edit the `.env` file and update the following required variables:

```bash
# Your domain name
DOMAIN=your-domain.com
OVERLEAF_SITE_URL=https://your-domain.com

# Admin email
OVERLEAF_ADMIN_EMAIL=admin@your-domain.com

# Security (generate strong passwords)
REDIS_PASSWORD=your-secure-redis-password

# SSL/Let's Encrypt email
ACME_EMAIL=admin@your-domain.com
```

### 3. Deploy with Deployment Script

For Linux/macOS:
```bash
# Make script executable
chmod +x scripts/deploy.sh

# Run deployment
./scripts/deploy.sh
```

For Windows (PowerShell):
```powershell
# Run the deployment manually using Docker Compose
docker-compose -f docker-compose.production.yml up -d
```

### 4. Initial Setup

1. Wait for all services to start (2-3 minutes)
2. Visit `http://your-domain.com/launchpad` to create the first admin user
3. Complete the setup wizard

## 🌐 Making Your Overleaf Accessible from the Internet

### Option 1: Using Your Own Server

#### A. DNS Configuration
1. Point your domain's A record to your server's IP address:
   ```
   Type: A
   Host: @
   Value: YOUR_SERVER_IP
   TTL: 300
   ```

2. Optionally add a www subdomain:
   ```
   Type: CNAME
   Host: www
   Value: your-domain.com
   TTL: 300
   ```

#### B. Firewall Configuration
Open the required ports on your server:
```bash
# Ubuntu/Debian
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# CentOS/RHEL
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload
```

### Option 2: Cloud Platform Deployment

#### A. DigitalOcean App Platform
1. Create a new app from this GitHub repository
2. Use the `docker-compose.production.yml` configuration
3. Add your environment variables in the dashboard
4. Deploy and get your public URL

#### B. AWS ECS/Fargate
1. Create an ECS cluster
2. Build and push the Docker image to ECR
3. Create ECS services using the provided configuration
4. Configure an Application Load Balancer

#### C. Google Cloud Run
1. Build the Docker image:
   ```bash
   docker build -f server-ce/Dockerfile -t gcr.io/PROJECT_ID/overleaf .
   ```
2. Push to Google Container Registry
3. Deploy to Cloud Run with appropriate environment variables

#### D. Azure Container Instances
1. Create a container group using the Docker Compose configuration
2. Configure the public IP and DNS name
3. Set up SSL with Azure Front Door

### Option 3: GitHub Codespaces (Development/Testing)

1. Create a Codespace from this repository
2. The Codespace will automatically forward port 80
3. Access via the provided GitHub Codespaces URL
4. Note: This is for development only, not production

## 🔒 SSL/HTTPS Configuration

### Automatic SSL with Let's Encrypt (Recommended)

The provided configuration includes Traefik for automatic SSL:

1. Ensure your domain is properly configured
2. Start with Traefik profile:
   ```bash
   docker-compose -f docker-compose.production.yml --profile traefik up -d
   ```
3. SSL certificates will be automatically obtained and renewed

### Manual SSL Configuration

If you prefer manual SSL setup:

1. Obtain SSL certificates from your preferred provider
2. Place certificates in `./ssl/` directory:
   ```
   ssl/
   ├── cert.pem
   └── privkey.pem
   ```
3. Uncomment SSL volume in `docker-compose.production.yml`
4. Configure nginx manually

## 📊 Monitoring and Maintenance

### Health Checks

Check service status:
```bash
# Using deployment script
./scripts/deploy.sh status

# Manual check
docker-compose -f docker-compose.production.yml ps
```

### Logs

View logs:
```bash
# All services
docker-compose -f docker-compose.production.yml logs -f

# Specific service
docker-compose -f docker-compose.production.yml logs -f sharelatex
```

### Automatic Updates

Enable Watchtower for automatic updates:
```bash
docker-compose -f docker-compose.production.yml --profile watchtower up -d
```

### Backup

Create regular backups of your data:
```bash
# Backup script
#!/bin/bash
docker run --rm \
  -v overleaf-production_mongo_data:/data/db \
  -v $(pwd)/backup:/backup \
  mongo:6.0 \
  mongodump --out /backup/$(date +%Y%m%d_%H%M%S)
```

## 🔧 Troubleshooting

### Common Issues

1. **Services not starting**: Check Docker logs for specific error messages
2. **Cannot access externally**: Verify DNS configuration and firewall settings
3. **SSL issues**: Ensure domain points to your server and port 443 is open
4. **Performance issues**: Increase server resources or enable caching

### Support Commands

```bash
# Restart all services
docker-compose -f docker-compose.production.yml restart

# Update services
docker-compose -f docker-compose.production.yml pull
docker-compose -f docker-compose.production.yml up -d

# Stop all services
docker-compose -f docker-compose.production.yml down

# Reset everything (⚠️ DANGER: This will delete all data)
docker-compose -f docker-compose.production.yml down -v
```

## 📝 Configuration Options

### Email Configuration

For user registration and notifications:
```bash
OVERLEAF_EMAIL_FROM_ADDRESS=noreply@your-domain.com
OVERLEAF_EMAIL_SMTP_HOST=smtp.gmail.com
OVERLEAF_EMAIL_SMTP_PORT=587
OVERLEAF_EMAIL_SMTP_USER=your-email@gmail.com
OVERLEAF_EMAIL_SMTP_PASS=your-app-password
```

### Customization

```bash
# Custom branding
OVERLEAF_NAV_TITLE="Your Organization LaTeX"
OVERLEAF_HEADER_IMAGE_URL=https://your-domain.com/logo.png

# Custom footer
OVERLEAF_LEFT_FOOTER='[{"text": "Powered by Your Organization"}]'
OVERLEAF_RIGHT_FOOTER='[{"text": "Support: support@your-domain.com"}]'
```

## 🏗️ Development

For local development, use the development environment:

```bash
cd develop
bin/build
bin/up
```

Access at http://localhost/launchpad

## 📚 Additional Resources

- [Overleaf Documentation](https://github.com/overleaf/overleaf/wiki)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the GNU AFFERO GENERAL PUBLIC LICENSE v3. See the [LICENSE](LICENSE) file for details.

---

**Need help?** Open an issue in the GitHub repository or check the [Overleaf Community](https://www.overleaf.com/help) for support.
