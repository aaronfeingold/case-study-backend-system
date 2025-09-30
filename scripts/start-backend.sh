#!/bin/bash

# Case Study Invoice Intelligence Development Startup Script
echo "🚀 Starting Case Study Invoice Intelligence System..."

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found. Copying from .env.example..."
    cp .env.example .env
    echo "📝 Please edit .env file with your configuration before continuing."
    exit 1
fi

# Load environment variables
export $(cat .env | grep -v '^#' | xargs)

# Change to docker directory
cd docker

# Start the services based on profile
case "${1:-full}" in
    "db")
        echo "🐳 Starting database services only..."
        docker-compose --profile local-db up -d
        ;;
    "api")
        echo "🔧 Starting API services..."
        docker-compose --profile api up -d
        ;;
    "worker")
        echo "⚙️  Starting worker services..."
        docker-compose --profile worker up -d
        ;;
    "monitoring")
        echo "📊 Starting monitoring services..."
        docker-compose --profile monitoring up -d
        ;;
    "full")
        echo "🐳 Starting all services..."
        docker-compose --profile full up -d
        ;;
    *)
        echo "Usage: $0 [db|api|worker|monitoring|full]"
        echo "  db        - Start database services only"
        echo "  api       - Start API services"
        echo "  worker    - Start worker services"
        echo "  monitoring - Start monitoring services"
        echo "  full      - Start all services (default)"
        exit 1
        ;;
esac

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check if services are healthy
echo "🔍 Checking service health..."
docker-compose ps

echo "✅ Case Study system started!"
echo "🔗 API available at: http://localhost:8000"
echo "🌐 Frontend available at: http://localhost:3000"
echo "📊 Flower monitoring at: http://localhost:5555 (if started)"
echo ""
echo "📝 To view logs: docker-compose logs -f [service-name]"
echo "🛑 To stop: docker-compose down"
echo ""
echo "Available services:"
echo "  - case-study-postgres (Database)"
echo "  - case-study-redis (Message broker)"
echo "  - case-study-api (Flask API)"
echo "  - case-study-worker (Celery worker)"
echo "  - case-study-flower (Monitoring)"
