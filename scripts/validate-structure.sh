#!/bin/bash
set -e

# Validation script for Case Study project structure
# Ensures all paths and configurations are correct

echo "🔍 Validating Case Study project structure..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0

check_file() {
    if [[ -f "$1" ]]; then
        echo -e "${GREEN}✅${NC} Found: $1"
    else
        echo -e "${RED}❌${NC} Missing: $1"
        ((ERRORS++))
    fi
}

check_dir() {
    if [[ -d "$1" ]]; then
        echo -e "${GREEN}✅${NC} Directory: $1"
    else
        echo -e "${RED}❌${NC} Missing directory: $1"
        ((ERRORS++))
    fi
}

# Get to project root
cd "$(dirname "$0")/../.."

echo -e "\n📁 Checking directory structure..."

# Core directories
check_dir "backend/api"
check_dir "backend/docker"
check_dir "backend/terraform"
check_dir "backend/monitoring"
check_dir "backend/terraform/modules"
check_dir "backend/terraform/environments"

echo -e "\n🐳 Checking Docker files..."

# Docker and API files
check_file "backend/api/Dockerfile"
check_file "backend/api/requirements.txt"
check_file "backend/api/app.py"
check_file "backend/docker/docker-compose.yml"

echo -e "\n🏗️ Checking Terraform files..."

# Terraform files
check_file "backend/terraform/main.tf"
check_file "backend/terraform/variables.tf"
check_file "backend/terraform/outputs.tf"

# Terraform modules
check_file "backend/terraform/modules/container-instance/main.tf"
check_file "backend/terraform/modules/container-instance/variables.tf"
check_file "backend/terraform/modules/container-instance/outputs.tf"
check_file "backend/terraform/modules/database/main.tf"
check_file "backend/terraform/modules/database/variables.tf"
check_file "backend/terraform/modules/database/outputs.tf"
check_file "backend/terraform/modules/monitoring/main.tf"
check_file "backend/terraform/modules/monitoring/variables.tf"
check_file "backend/terraform/modules/monitoring/outputs.tf"

# Environment configs
check_file "backend/terraform/environments/dev/terraform.tfvars"
check_file "backend/terraform/environments/prod/terraform.tfvars"

echo -e "\n📊 Checking monitoring configuration..."

# Monitoring configs
check_file "backend/monitoring/prometheus/prometheus.yml"
check_file "backend/monitoring/prometheus/alert_rules.yml"
check_file "backend/monitoring/grafana/datasources/prometheus.yml"
check_file "backend/monitoring/grafana/dashboards/dashboard.yml"
check_file "backend/monitoring/alertmanager/alertmanager.yml"

# Terraform monitoring templates
check_file "backend/terraform/modules/monitoring/config/prometheus.yml.tpl"
check_file "backend/terraform/modules/monitoring/config/alert_rules.yml"
check_file "backend/terraform/modules/monitoring/config/grafana-datasource.yml.tpl"
check_file "backend/terraform/modules/monitoring/config/alertmanager.yml.tpl"

echo -e "\n⚙️ Checking CI/CD files..."

# CI/CD files
check_file ".github/workflows/deploy.yml"

echo -e "\n🔬 Checking API structure..."

# API structure
check_file "backend/api/app/services/metrics_service.py"
check_file "backend/api/app/routes/health.py"

echo -e "\n📝 Validating Docker Compose references..."

# Check if docker-compose references are correct
if grep -q "../api" backend/docker/docker-compose.yml; then
    echo -e "${GREEN}✅${NC} Docker Compose correctly references API directory"
else
    echo -e "${RED}❌${NC} Docker Compose API path incorrect"
    ((ERRORS++))
fi

echo -e "\n🔗 Validating Terraform module references..."

# Check Terraform module references
if grep -q "./modules/" backend/terraform/main.tf; then
    echo -e "${GREEN}✅${NC} Terraform correctly references local modules"
else
    echo -e "${RED}❌${NC} Terraform module paths may be incorrect"
    ((ERRORS++))
fi

echo -e "\n📋 Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ $ERRORS -eq 0 ]]; then
    echo -e "${GREEN}🎉 All checks passed! Project structure is valid.${NC}"
    echo -e "\n${GREEN}Ready for deployment:${NC}"
    echo "  • Local development: cd backend/docker && docker-compose --profile full up"
    echo "  • Azure deployment: cd backend/terraform && terraform init && terraform plan"
    echo "  • CI/CD ready: Push to main branch to trigger deployment"
else
    echo -e "${RED}❌ Found $ERRORS error(s). Please fix the issues above.${NC}"
    exit 1
fi

echo -e "\n${YELLOW}💡 Next steps:${NC}"
echo "  1. Set up GitHub secrets for Azure deployment"
echo "  2. Configure Azure Container Registry credentials"
echo "  3. Test local monitoring stack"
echo "  4. Run terraform plan to validate Azure resources"
