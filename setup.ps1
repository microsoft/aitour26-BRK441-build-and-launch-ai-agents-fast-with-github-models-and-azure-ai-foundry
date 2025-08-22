# Quick Setup Script for Chat Demo
# Run this script to quickly set up and start the chat demo

Write-Host "🤖 Setting up AI Agent Chat Demo..." -ForegroundColor Cyan

# Check if Python is installed
try {
    $pythonVersion = python --version 2>&1
    Write-Host "✅ Python found: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Python not found. Please install Python 3.8 or higher." -ForegroundColor Red
    exit 1
}

# Install dependencies
Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
pip install -r requirements.txt

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to install dependencies." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Dependencies installed successfully!" -ForegroundColor Green

# Start the application
Write-Host "🚀 Starting the chat demo..." -ForegroundColor Cyan
Write-Host "📱 Open your browser and go to: http://localhost:8000" -ForegroundColor Magenta
Write-Host "🛑 Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

python app.py
