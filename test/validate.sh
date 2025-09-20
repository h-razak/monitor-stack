#!/bin/bash

# Comprehensive Testing Script for Datacenter Monitoring Stack
# This script validates all configurations before deployment

set -e

echo "🧪 DATACENTER MONITORING - VALIDATION SUITE"
echo "============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
        ((ERRORS++))
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNINGS++))
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

echo -e "${BLUE}🔍 Phase 1: File Structure Validation${NC}"
echo "======================================"

# Check required files exist
REQUIRED_FILES=(
    ".env"
    "docker-compose.yml"
    "README.md"
    "GUI_SETUP_GUIDE.md"
    "PROXMOX_API_SETUP.md"
    "GRAFANA_ALERTING_GUIDE.md"
    "config/prometheus/prometheus.yml"
    "config/grafana/provisioning/datasources/datasources.yml"
    "config/blackbox/blackbox.yml"
    "config/loki/local-config.yaml"
    "config/promtail/config.yml"
    "config/snmp/snmp.yml"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        print_status 0 "Required file exists: $file"
    else
        print_status 1 "Missing required file: $file"
    fi
done

# Check required directories
REQUIRED_DIRS=(
    "config"
    "config/prometheus"
    "config/grafana/provisioning/datasources"
    "config/blackbox"
    "config/loki"
    "config/promtail"
    "config/snmp"
    "dashboards"
    "scripts"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        print_status 0 "Required directory exists: $dir"
    else
        print_status 1 "Missing required directory: $dir"
    fi
done

echo ""
echo -e "${BLUE}🐳 Phase 2: Docker Compose Validation${NC}"
echo "===================================="

# Test docker-compose syntax
if docker-compose config > /dev/null 2>&1; then
    print_status 0 "Docker Compose syntax valid"
else
    print_status 1 "Docker Compose syntax error"
    echo "Run 'docker-compose config' for details"
fi

# Check for environment variables in .env
if [ -f ".env" ]; then
    # Check critical environment variables
    ENV_VARS=(
        "MONITORING_VM_IP"
        "PROXMOX_NODE_1"
        "PVE_API_USER"
        "PVE_API_PASSWORD"
        "GRAFANA_ADMIN_USER"
        "GRAFANA_ADMIN_PASSWORD"
    )
    
    for var in "${ENV_VARS[@]}"; do
        if grep -q "^${var}=" .env; then
            print_status 0 "Environment variable defined: $var"
        else
            print_status 1 "Missing environment variable: $var"
        fi
    done
else
    print_status 1 ".env file missing"
fi

echo ""
echo -e "${BLUE}⚙️  Phase 3: Configuration File Validation${NC}"
echo "========================================"

# Test Prometheus config
if command -v promtool > /dev/null 2>&1; then
    if promtool check config config/prometheus/prometheus.yml > /dev/null 2>&1; then
        print_status 0 "Prometheus configuration valid"
    else
        print_status 1 "Prometheus configuration invalid"
    fi
else
    print_warning "promtool not available, skipping Prometheus validation"
fi

# Test YAML syntax for config files
YAML_FILES=(
    "config/prometheus/prometheus.yml"
    "config/grafana/provisioning/datasources/datasources.yml"
    "config/blackbox/blackbox.yml"
    "config/loki/local-config.yaml"
    "config/promtail/config.yml"
    "config/snmp/snmp.yml"
)

for yaml_file in "${YAML_FILES[@]}"; do
    if [ -f "$yaml_file" ]; then
        if python3 -c "import yaml; yaml.safe_load(open('$yaml_file'))" 2>/dev/null; then
            print_status 0 "YAML syntax valid: $yaml_file"
        else
            print_status 1 "YAML syntax error: $yaml_file"
        fi
    fi
done

echo ""
echo -e "${BLUE}🌐 Phase 4: Network Configuration Validation${NC}"
echo "==========================================="

# Check IP format in .env
if [ -f ".env" ]; then
    # Extract and validate IP addresses
    IPS=$(grep -E "^[A-Z_]*=10\." .env | cut -d'=' -f2)
    for ip in $IPS; do
        if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            print_status 0 "Valid IP format: $ip"
        else
            print_status 1 "Invalid IP format: $ip"
        fi
    done
fi

# Check for required ports
REQUIRED_PORTS=(
    "3000"   # Grafana
    "9090"   # Prometheus
    "9221"   # PVE Exporter
    "9115"   # Blackbox
    "9100"   # Node Exporter
)

for port in "${REQUIRED_PORTS[@]}"; do
    if grep -q ":${port}" docker-compose.yml; then
        print_status 0 "Port configuration found: $port"
    else
        print_status 1 "Missing port configuration: $port"
    fi
done

echo ""
echo -e "${BLUE}📊 Phase 5: Dashboard Validation${NC}"
echo "==============================="

# Check dashboard files
if [ -d "dashboards" ]; then
    DASHBOARD_COUNT=$(find dashboards -name "*.json" | wc -l)
    if [ $DASHBOARD_COUNT -gt 0 ]; then
        print_status 0 "Dashboard files found: $DASHBOARD_COUNT"
        
        # Validate JSON syntax
        for dashboard in dashboards/*.json; do
            if [ -f "$dashboard" ]; then
                if python3 -c "import json; json.load(open('$dashboard'))" 2>/dev/null; then
                    print_status 0 "Valid JSON: $(basename $dashboard)"
                else
                    print_status 1 "Invalid JSON: $(basename $dashboard)"
                fi
            fi
        done
    else
        print_warning "No dashboard files found in dashboards/"
    fi
fi

echo ""
echo -e "${BLUE}🔧 Phase 6: Script Validation${NC}"
echo "============================"

# Check script files
if [ -d "scripts" ]; then
    for script in scripts/*.sh; do
        if [ -f "$script" ]; then
            if bash -n "$script" 2>/dev/null; then
                print_status 0 "Script syntax valid: $(basename $script)"
            else
                print_status 1 "Script syntax error: $(basename $script)"
            fi
            
            # Check if executable
            if [ -x "$script" ]; then
                print_status 0 "Script is executable: $(basename $script)"
            else
                print_warning "Script not executable: $(basename $script)"
            fi
        fi
    done
fi

echo ""
echo -e "${BLUE}📋 Phase 7: Documentation Check${NC}"
echo "==============================="

# Check documentation files
DOC_FILES=(
    "README.md"
    "GUI_SETUP_GUIDE.md"
    "PROXMOX_API_SETUP.md"
    "GRAFANA_ALERTING_GUIDE.md"
    "API_MONITORING_GUIDE.md"
    "VM_MONITORING_TEMPLATE.md"
)

for doc in "${DOC_FILES[@]}"; do
    if [ -f "$doc" ]; then
        word_count=$(wc -w < "$doc")
        if [ $word_count -gt 100 ]; then
            print_status 0 "Documentation complete: $doc ($word_count words)"
        else
            print_warning "Documentation seems incomplete: $doc ($word_count words)"
        fi
    else
        print_status 1 "Missing documentation: $doc"
    fi
done

echo ""
echo "============================================="
echo -e "${BLUE}📊 VALIDATION SUMMARY${NC}"
echo "============================================="

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL CHECKS PASSED!${NC}"
    echo -e "${GREEN}✅ Your monitoring stack is ready for deployment${NC}"
else
    echo -e "${RED}❌ $ERRORS ERRORS FOUND${NC}"
    echo -e "${RED}🛠️  Please fix the errors before deployment${NC}"
fi

if [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  $WARNINGS WARNINGS${NC}"
    echo -e "${YELLOW}💡 Consider reviewing the warnings${NC}"
fi

echo ""
echo -e "${BLUE}🚀 Next Steps:${NC}"
if [ $ERRORS -eq 0 ]; then
    echo "1. Review and customize .env file"
    echo "2. Create Proxmox API user (see PROXMOX_API_SETUP.md)"
    echo "3. Run: docker-compose up -d"
    echo "4. Access Grafana at http://your-ip:3000"
else
    echo "1. Fix the errors listed above"
    echo "2. Run this test script again"
    echo "3. Proceed with deployment once all tests pass"
fi

exit $ERRORS
