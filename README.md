# 🏢## 🚀 Quick Deployment (3 Steps)

### Step 1: Copy to Your Monitoring Server
```bash
# Copy this entire monitoring/ directory to your server
scp -r monitoring/ user@10.20.10.34:/home/user/
```

### Step 2: Configure Your Environment
```bash
# Edit .env file with your actual network details
cd monitoring/
nano .env

# Update these key settings:
# MONITORING_VM_IP=10.20.10.34 (your monitoring server IP)
# PROXMOX_NODE_1=10.20.10.11 (your first Proxmox node)
# PROXMOX_NODE_2=10.20.10.12 (your second Proxmox node)
# ... (update all 6 nodes)
# PVE_API_USER=monitoring@pve
# PVE_API_PASSWORD=monitoring123
```

### Step 3: Create Proxmox API User  
**Follow**: `PROXMOX_API_SETUP.md` for complete GUI-based setup

### Step 4: Deploy & Access
```bash
# Start the monitoring stack
docker-compose up -d

# Access your dashboards
# Grafana: http://10.20.10.34:3000 (admin/admin123)
# Prometheus: http://10.20.10.34:9090
```

**Result**: Complete datacenter monitoring with automatic VM/LXC discovery! 🎉oring Stack

**Complete Docker-based monitoring solution for Proxmox clusters with GUI-first configuration**

## 🎯 Quick Start (3 Steps)

### 1. Configure Your Environment
```bash
# Edit .env file with your network details
nano .env
```

### 2. Create Proxmox API User  
**See**: `PROXMOX_API_SETUP.md` for GUI-based setup

### 3. Deploy
```bash
docker-compose up -d
```

**Result**: Full monitoring dashboard at `http://your-server:3000` (admin/admin123)

---

## 📊 What Gets Monitored

- ✅ **All Proxmox VMs/LXC** (automatic API discovery)
- ✅ **Host System Metrics** (CPU, memory, disk, network)  
- ✅ **Docker Containers** (resource usage, health)
- ✅ **Network Connectivity** (uptime, latency, SSL certificates)
- ✅ **FortiGate Firewall** (SNMP monitoring)
- ✅ **System Logs** (centralized log aggregation)

## 🖱️ GUI-First Philosophy

**99% configuration through web interfaces:**
- **Dashboards**: Import and customize via Grafana GUI
- **Alerts**: Visual rule builder in Grafana
- **Users**: Grafana user management interface
- **API Setup**: Proxmox web interface
- **Monitoring**: All viewing through Grafana dashboards

**Only 1 config file to edit**: `.env` (your network settings)

---

## 📁 Repository Structure

```
monitoring/
├── .env                    # 🔧 YOUR SETTINGS (only file you edit)
├── docker-compose.yml      # 🐳 Service orchestration
├── config/                 # ⚙️ Internal service configs
├── dashboards/             # 📊 Import-ready Grafana dashboards
├── test/                   # ✅ Validation scripts
└── *.md                    # 📖 Complete setup guides
```

## 🌐 Access Points

| Service | URL | Purpose |
|---------|-----|---------|
| **Grafana** | `http://your-server:3000` | Main monitoring dashboard |
| **Prometheus** | `http://your-server:9090` | Metrics browser |
| **Uptime Kuma** | `http://your-server:3001` | Uptime monitoring |

## 📖 Documentation

- **`GUI_SETUP_GUIDE.md`** - Complete walkthrough for GUI-based setup
- **`PROXMOX_API_SETUP.md`** - Step-by-step API user creation  
- **`GRAFANA_ALERTING_GUIDE.md`** - Visual alert configuration
- **`VALIDATION_COMPLETE.md`** - Deployment readiness confirmation

## 🔧 Customization

- **Network Settings**: Edit `.env` file
- **Dashboards**: Import/modify via Grafana GUI
- **Alerts**: Configure through Grafana interface
- **Users**: Manage via Grafana administration panel

**No YAML editing required!** 🎉

---

## ✅ Validation

```bash
# Test configuration before deployment
./test/quick-test.sh

# Comprehensive validation
./test/validate.sh
```

## 🆘 Support

1. **Health Check**: `docker-compose ps`
2. **View Logs**: `docker-compose logs [service]`
3. **Restart Service**: `docker-compose restart [service]`
4. **Full Reset**: `docker-compose down && docker-compose up -d`

---

**📈 Enterprise-ready monitoring with friendly configuration - Ready to push to your repo!** 🚀
