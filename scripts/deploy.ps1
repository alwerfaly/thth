# Overleaf Deployment Script for Windows PowerShell
# This script automates the deployment of Overleaf Community Edition on Windows

param(
    [Parameter(Position=0)]
    [ValidateSet("deploy", "start", "stop", "restart", "status", "logs", "update")]
    [string]$Action = "deploy"
)

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Cyan"

function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor $Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $Yellow
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Red
}

function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

function Test-Prerequisites {
    Write-Status "Checking prerequisites..."
    
    if (-not (Test-Command "docker")) {
        Write-Error-Custom "Docker is not installed. Please install Docker Desktop first."
        exit 1
    }
    
    if (-not (Test-Command "docker-compose")) {
        Write-Error-Custom "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    }
    
    if (-not (Test-Path ".env")) {
        Write-Warning ".env file not found. Creating from example..."
        if (Test-Path "env.example") {
            Copy-Item "env.example" ".env"
            Write-Warning "Please edit .env file with your configuration before continuing."
            exit 1
        } else {
            Write-Error-Custom "env.example file not found. Cannot create .env file."
            exit 1
        }
    }
    
    Write-Success "Prerequisites check passed!"
}

function Build-TexLive {
    Write-Status "Building TeX Live image..."
    if (Test-Path "develop\texlive") {
        docker build develop\texlive -t texlive-full
        Write-Success "TeX Live image built successfully!"
    } else {
        Write-Warning "TeX Live directory not found. Skipping TeX Live build."
    }
}

function Start-Services {
    Write-Status "Starting Overleaf services..."
    
    # Pull latest images
    docker-compose -f docker-compose.production.yml pull
    
    # Start services
    docker-compose -f docker-compose.production.yml up -d
    
    Write-Success "Services started successfully!"
}

function Wait-ForServices {
    Write-Status "Waiting for services to be healthy..."
    
    # Wait for MongoDB
    Write-Status "Waiting for MongoDB..."
    $timeout = 60
    while ($timeout -gt 0) {
        try {
            $result = docker-compose -f docker-compose.production.yml exec -T mongo mongosh --eval "db.stats()" 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Success "MongoDB is ready!"
                break
            }
        } catch {
            # Continue waiting
        }
        Start-Sleep -Seconds 5
        $timeout -= 5
    }
    
    if ($timeout -eq 0) {
        Write-Error-Custom "MongoDB failed to start within 60 seconds"
        exit 1
    }
    
    # Wait for Overleaf
    Write-Status "Waiting for Overleaf..."
    $timeout = 120
    while ($timeout -gt 0) {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost/status" -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                Write-Success "Overleaf is ready!"
                break
            }
        } catch {
            # Continue waiting
        }
        Start-Sleep -Seconds 10
        $timeout -= 10
    }
    
    if ($timeout -eq 0) {
        Write-Error-Custom "Overleaf failed to start within 120 seconds"
        exit 1
    }
}

function Show-Status {
    Write-Status "Current service status:"
    docker-compose -f docker-compose.production.yml ps
    
    Write-Host ""
    Write-Success "Deployment completed successfully!"
    Write-Status "You can access Overleaf at:"
    
    if (Test-Path ".env") {
        $envContent = Get-Content ".env"
        $domainLine = $envContent | Where-Object { $_ -match "^DOMAIN=" }
        if ($domainLine) {
            $domain = ($domainLine -split "=")[1]
            if ($domain -and $domain -ne "your-domain.com") {
                Write-Host "  https://$domain"
            }
        }
    }
    
    Write-Host "  http://localhost (if running locally)"
    Write-Host ""
    Write-Status "To create the first admin user, visit:"
    Write-Host "  http://localhost/launchpad"
}

function Invoke-Deploy {
    Write-Host "=================================" -ForegroundColor $Blue
    Write-Host "Overleaf Deployment Script" -ForegroundColor $Blue
    Write-Host "=================================" -ForegroundColor $Blue
    Write-Host ""
    
    Test-Prerequisites
    Build-TexLive
    Start-Services
    Wait-ForServices
    Show-Status
}

# Main script logic
switch ($Action) {
    "start" {
        Start-Services
    }
    "stop" {
        Write-Status "Stopping services..."
        docker-compose -f docker-compose.production.yml down
        Write-Success "Services stopped!"
    }
    "restart" {
        Write-Status "Restarting services..."
        docker-compose -f docker-compose.production.yml restart
        Write-Success "Services restarted!"
    }
    "status" {
        Show-Status
    }
    "logs" {
        docker-compose -f docker-compose.production.yml logs -f
    }
    "update" {
        Write-Status "Updating services..."
        docker-compose -f docker-compose.production.yml pull
        docker-compose -f docker-compose.production.yml up -d
        Write-Success "Services updated!"
    }
    default {
        Invoke-Deploy
    }
}
