# GitHub Repository Setup Guide

Follow these steps to upload your Overleaf project to GitHub and make it accessible via a public link.

## 📋 Prerequisites

- Git installed on your system
- GitHub account
- Basic knowledge of Git commands

## 🔧 Step-by-Step Setup

### 1. Initialize Git Repository

```bash
# Initialize git repository (if not already done)
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Overleaf Community Edition with production deployment"
```

### 2. Create GitHub Repository

1. Go to [GitHub](https://github.com) and log in
2. Click "New" or "+" → "New repository"
3. Name your repository (e.g., `overleaf-community-edition`)
4. Choose "Public" for public access
5. **Do NOT** initialize with README, .gitignore, or license (we already have these)
6. Click "Create repository"

### 3. Connect Local Repository to GitHub

```bash
# Add GitHub remote (replace YOUR_USERNAME and REPOSITORY_NAME)
git remote add origin https://github.com/YOUR_USERNAME/REPOSITORY_NAME.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### 4. Configure Repository Settings

#### A. Enable GitHub Actions
1. Go to your repository → "Actions" tab
2. GitHub Actions should be enabled by default
3. The workflow will run automatically on push

#### B. Configure Environments (Optional)
1. Go to "Settings" → "Environments"
2. Create a "production" environment
3. Add environment protection rules if needed

#### C. Enable GitHub Pages (Optional)
1. Go to "Settings" → "Pages"
2. Source: "Deploy from a branch"
3. Branch: "main" → "/ (root)"
4. This will make documentation accessible via GitHub Pages

### 5. Configure Secrets (For Production Deployment)

If using GitHub Actions for deployment:

1. Go to "Settings" → "Secrets and variables" → "Actions"
2. Add the following secrets:
   - `DOCKER_USERNAME`: Your Docker Hub username
   - `DOCKER_PASSWORD`: Your Docker Hub password
   - `DEPLOY_HOST`: Your production server IP
   - `DEPLOY_USERNAME`: Server username
   - `DEPLOY_SSH_KEY`: SSH private key for server access

## 🌐 Making Your Overleaf Accessible

### Option 1: GitHub Codespaces (Development/Testing)
1. Go to your repository on GitHub
2. Click "Code" → "Codespaces" → "Create codespace on main"
3. Wait for the codespace to start
4. Run deployment in the terminal:
   ```bash
   chmod +x scripts/deploy.sh
   ./scripts/deploy.sh
   ```
5. Access via the forwarded port URL

### Option 2: Deploy to Cloud Platform

#### DigitalOcean App Platform
1. Connect your GitHub repository to DigitalOcean
2. Use the `docker-compose.production.yml` configuration
3. Set environment variables in the dashboard
4. Deploy and get your public URL

#### Heroku Container
```bash
# Install Heroku CLI
# Login to Heroku
heroku login

# Create app
heroku create your-app-name

# Set config vars
heroku config:set OVERLEAF_SITE_URL=https://your-app-name.herokuapp.com

# Deploy
git push heroku main
```

#### Google Cloud Run
```bash
# Build and deploy
gcloud run deploy overleaf \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

### Option 3: Your Own Server

1. **Get a server** (VPS from AWS, DigitalOcean, Linode, etc.)
2. **Point your domain** to the server IP
3. **SSH into your server** and clone the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/REPOSITORY_NAME.git
   cd REPOSITORY_NAME
   cp env.example .env
   # Edit .env with your domain
   ./scripts/deploy.sh
   ```

## 📝 Repository Features

Your repository now includes:

### ✅ Production Ready
- Docker-based deployment
- SSL/HTTPS with Let's Encrypt
- Health checks and monitoring
- Automatic updates capability

### ✅ CI/CD Pipeline
- Automated testing on pull requests
- Docker image building and publishing
- Deployment automation

### ✅ Documentation
- Comprehensive deployment guide
- Environment configuration examples
- Troubleshooting instructions

### ✅ Monitoring (Optional)
- Prometheus metrics collection
- Grafana dashboards
- Uptime monitoring

## 🔗 Access URLs

After deployment, your Overleaf will be accessible at:

- **Production**: `https://your-domain.com`
- **Admin Setup**: `https://your-domain.com/launchpad`
- **Monitoring** (if enabled): `https://grafana.your-domain.com`

## 🚀 Next Steps

1. **Test your deployment** by creating the first admin user
2. **Configure email settings** for user registration
3. **Set up monitoring** for production environments
4. **Create backups** of your data
5. **Share your repository** with others

## 📚 Additional Resources

- [DEPLOYMENT.md](DEPLOYMENT.md) - Complete deployment guide
- [Overleaf Documentation](https://github.com/overleaf/overleaf/wiki)
- [Docker Documentation](https://docs.docker.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

**Need help?** Open an issue in your GitHub repository or check the [Overleaf Community](https://www.overleaf.com/help) for support.
