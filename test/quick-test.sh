#!/bin/bash

# Quick Test Script - Fast validation for critical components
# Use this for quick checks during development

echo "🚀 QUICK VALIDATION TEST"
echo "======================="

ERRORS=0

# Test 1: Docker Compose syntax
echo "Testing Docker Compose..."
if docker-compose config > /dev/null 2>&1; then
    echo "✅ Docker Compose: OK"
else
    echo "❌ Docker Compose: FAILED"
    ((ERRORS++))
fi

# Test 2: Required files
echo "Checking required files..."
CRITICAL_FILES=(".env" "docker-compose.yml" "config/prometheus/prometheus.yml")
for file in "${CRITICAL_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file: EXISTS"
    else
        echo "❌ $file: MISSING"
        ((ERRORS++))
    fi
done

# Test 3: YAML syntax
echo "Testing YAML syntax..."
YAML_FILES=("config/prometheus/prometheus.yml" "config/grafana/provisioning/datasources/datasources.yml")
for yaml_file in "${YAML_FILES[@]}"; do
    if python3 -c "import yaml; yaml.safe_load(open('$yaml_file'))" 2>/dev/null; then
        echo "✅ $yaml_file: VALID"
    else
        echo "❌ $yaml_file: INVALID"
        ((ERRORS++))
    fi
done

# Test 4: Environment variables
echo "Checking environment variables..."
if [ -f ".env" ] && grep -q "PVE_API_USER" .env && grep -q "PROXMOX_NODE_1" .env; then
    echo "✅ Environment: CONFIGURED"
else
    echo "❌ Environment: INCOMPLETE"
    ((ERRORS++))
fi

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "🎉 QUICK TEST PASSED - Ready for deployment!"
else
    echo "💥 $ERRORS ERRORS FOUND - Run ./test/validate.sh for details"
fi

exit $ERRORS
