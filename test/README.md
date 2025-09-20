# Test Directory

This directory contains validation scripts to ensure your monitoring stack is properly configured before deployment.

## Scripts

### 🧪 validate.sh
**Comprehensive validation suite**
- Tests all configuration files
- Validates YAML syntax
- Checks Docker Compose structure
- Verifies documentation completeness
- Validates network configuration

```bash
chmod +x test/validate.sh
./test/validate.sh
```

### ⚡ quick-test.sh
**Fast validation for critical components**
- Quick syntax checks
- Essential file validation
- Environment variable verification

```bash
chmod +x test/quick-test.sh
./test/quick-test.sh
```

## Usage

### Before Deployment
Always run the validation suite before starting your monitoring stack:

```bash
# Full validation
./test/validate.sh

# If all tests pass:
docker-compose up -d
```

### During Development
Use quick test for rapid iteration:

```bash
# After making changes
./test/quick-test.sh

# Fix any issues and test again
```

## What Gets Tested

### File Structure
- ✅ All required configuration files present
- ✅ Directory structure complete
- ✅ Scripts are executable

### Configuration Syntax
- ✅ Docker Compose YAML syntax
- ✅ Prometheus configuration validity
- ✅ All YAML configuration files
- ✅ JSON dashboard files

### Environment Setup
- ✅ .env file completeness
- ✅ Required environment variables
- ✅ IP address format validation
- ✅ Port configuration

### Documentation
- ✅ All required guides present
- ✅ Documentation completeness check
- ✅ No outdated files

## Error Resolution

### Common Issues

#### Docker Compose Errors
```bash
# Check syntax details
docker-compose config
```

#### YAML Syntax Errors
```bash
# Test specific file
python3 -c "import yaml; yaml.safe_load(open('config/prometheus/prometheus.yml'))"
```

#### Missing Environment Variables
```bash
# Check .env file
cat .env | grep -E "(PVE_API|PROXMOX_NODE|GRAFANA)"
```

### Fixing Errors

1. **Run full validation**: `./test/validate.sh`
2. **Fix reported errors**: Follow error messages
3. **Test again**: `./test/quick-test.sh`
4. **Deploy when clean**: `docker-compose up -d`

## Success Indicators

### Full Test Pass
```
🎉 ALL CHECKS PASSED!
✅ Your monitoring stack is ready for deployment
```

### Quick Test Pass
```
🎉 QUICK TEST PASSED - Ready for deployment!
```

When you see these messages, your monitoring stack is validated and ready for production deployment.
