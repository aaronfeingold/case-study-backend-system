#!/bin/bash

# Case Study Monitoring Stack Startup Script
# This script starts the complete monitoring infrastructure

set -e

echo "🚀 Starting Case Study Monitoring Stack..."

# Change to the docker directory
cd "$(dirname "$0")/../docker"

# Check if .env file exists, create a basic one if not
if [ ! -f .env ]; then
    echo "📝 Creating default .env file..."
    cat > .env << EOF
POSTGRES_DB=case-study
POSTGRES_USER=case-study
POSTGRES_PASSWORD=password
GRAFANA_PASSWORD=admin
EOF
fi

# Ensure monitoring directories exist
echo "📁 Setting up monitoring directories..."
mkdir -p ../monitoring/{prometheus,grafana/{dashboards,datasources},alertmanager}

# Start the monitoring stack
echo "🔧 Starting monitoring services..."
docker-compose --profile monitoring up -d

echo "⏳ Waiting for services to be ready..."
sleep 10

# Health check function
check_service() {
    local service_name=$1
    local url=$2
    local max_attempts=30
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        if curl -s -f "$url" > /dev/null 2>&1; then
            echo "✅ $service_name is ready"
            return 0
        fi
        echo "⏳ Waiting for $service_name (attempt $attempt/$max_attempts)..."
        sleep 2
        ((attempt++))
    done
    echo "❌ $service_name failed to start"
    return 1
}

# Check if services are ready
echo "🔍 Performing health checks..."
check_service "Prometheus" "http://localhost:9090/-/healthy"
check_service "Grafana" "http://localhost:3001/api/health"
check_service "Node Exporter" "http://localhost:9100/metrics"

# Show service URLs
echo ""
echo "🎉 Case Study Monitoring Stack is ready!"
echo ""
echo "📊 Monitoring Services:"
echo "  Prometheus:     http://localhost:9090"
echo "  Grafana:        http://localhost:3001 (admin/admin)"
echo "  AlertManager:   http://localhost:9093"
echo "  Node Exporter:  http://localhost:9100"
echo ""
echo "🐳 Infrastructure Services:"
echo "  PostgreSQL:     localhost:5433"
echo "  Redis:          localhost:6379"
echo ""
echo "🔧 Application Services (if running):"
echo "  Flask API:      http://localhost:8000"
echo "  Celery Flower:  http://localhost:5555"
echo ""
echo "To start all services including the app:"
echo "  docker-compose --profile full up -d"
echo ""
echo "To stop all services:"
echo "  docker-compose down"
echo ""
echo "To view logs:"
echo "  docker-compose logs -f [service-name]"