# 🖥️ GUI-Focused Datacenter Monitoring Setup

## 🎯 Philosophy: GUI First, Config Files Only When Necessary

This setup maximizes GUI-based configuration while keeping efficient internal Docker communication. You'll manage most settings through web interfaces, not config files.

## 📋 What's GUI vs Config File

### ✅ Managed via GUI (Recommended)
- **Proxmox API User**: Created through Proxmox web interface
- **Grafana Dashboards**: Imported and customized via Grafana GUI
- **Alert Rules**: Configured through Grafana alerting interface
- **Data Source Settings**: Auto-provisioned but editable in Grafana
- **User Management**: Grafana users and permissions
- **Dashboard Customization**: All visual changes via web interface

### ⚙️ Config Files (Internal Efficiency)
- **Service Communication**: Prometheus ↔ Grafana ↔ Loki (Docker networking)
- **Metric Collection**: Internal scrape configurations
- **Log Parsing**: Promtail log processing rules
- **Network Probes**: Blackbox exporter modules

---

## 🚀 Quick Start (3 Steps)

### Step 1: Configure Environment (.env file)
Edit `.env` file with your network details:
```bash
# Your network settings
MONITORING_VM_IP=10.20.10.34
PROXMOX_NODE_1=10.20.10.11
PROXMOX_NODE_2=10.20.10.12
# ... (edit all 6 nodes)

# API credentials (create via GUI in Step 2)
PVE_API_USER=monitoring@pve
PVE_API_PASSWORD=monitoring123
```

### Step 2: Create Proxmox API User (GUI)
See detailed guide: `PROXMOX_API_SETUP.md`

### Step 3: Start Monitoring
```bash
docker-compose up -d
```

**Result**: Everything works automatically!

---

## 🖱️ GUI Configuration Workflows

### 1. Proxmox API Setup (5 minutes)
**Location**: Proxmox web interface
**Access**: `https://10.20.10.11:8006` (any node)
**Guide**: See `PROXMOX_API_SETUP.md`
**Result**: All VMs/LXCs automatically discovered

### 2. Grafana Dashboard Import (2 minutes)
**Location**: `http://10.20.10.34:3000`
**Login**: admin / admin123
**Steps**:
1. Go to **+ (Plus)** → **Import**
2. Upload `dashboards/import-ready-datacenter.json`
3. Customize panels as needed
**Result**: Visual monitoring dashboards

### 3. Alert Configuration (10 minutes)
**Location**: Grafana → **Alerting** → **Alert Rules**
**Guide**: See `GRAFANA_ALERTING_GUIDE.md`
**Steps**:
1. Create contact points (email, slack, etc.)
2. Define alert rules (CPU > 80%, server down, etc.)
3. Set notification policies
**Result**: Automated alerting via GUI

### 4. User Management (Optional)
**Location**: Grafana → **Administration** → **Users**
**Steps**:
1. Create additional users
2. Assign roles and permissions
3. Set up teams and folders
**Result**: Multi-user access control

---

## 📁 Repository Structure

```
monitoring/
├── .env                          # 🔧 YOUR SETTINGS (edit this)
├── docker-compose.yml            # 🐳 Service definitions
├── 
├── config/                       # ⚙️ Internal service configs
│   ├── prometheus/               # Metrics collection rules
│   ├── grafana/provisioning/     # Auto data source setup
│   ├── blackbox/                 # Network monitoring
│   ├── loki/                     # Log aggregation
│   └── promtail/                 # Log collection
│
├── dashboards/                   # 📊 GUI import files
│   └── import-ready-*.json       # Import via Grafana GUI
│
├── guides/                       # 📖 Step-by-step instructions
│   ├── PROXMOX_API_SETUP.md      # GUI API user creation
│   ├── GRAFANA_DASHBOARD_GUIDE.md # Dashboard import & customization
│   └── ALERTING_SETUP.md         # GUI alert configuration
│
└── scripts/                      # 🔧 Optional automation
    └── install-node-exporter.sh  # For Proxmox host monitoring
```

---

## 🎨 Customization Workflows

### Adding New Servers
1. **Edit .env**: Add new IP addresses
2. **Restart stack**: `docker-compose restart`
3. **Grafana**: Dashboards automatically include new targets

### Custom Dashboards
1. **Grafana GUI**: Create/modify dashboards visually
2. **Export**: Dashboard → Share → Export → Save JSON
3. **Version Control**: Optionally save custom dashboards to `dashboards/`

### Alert Modifications
1. **Grafana GUI**: Alerting → Alert Rules
2. **Visual Editor**: Create rules with dropdown menus
3. **Test**: Use built-in testing tools
4. **No Config Files**: Everything managed in GUI

### User Access
1. **Grafana GUI**: Administration → Users/Teams
2. **LDAP/OAuth**: Connect external authentication
3. **Permissions**: Folder-based access control
4. **API Keys**: Programmatic access via GUI

---

## 🔧 Configuration Philosophy

### What You Edit:
- ✅ `.env` file (network settings, credentials)
- ✅ Grafana GUI (dashboards, alerts, users)
- ✅ Proxmox GUI (API users, permissions)

### What You Don't Touch:
- ❌ Docker Compose service definitions
- ❌ Prometheus scrape configs (auto-generated)
- ❌ Internal communication settings
- ❌ Log parsing rules

### Benefits:
- 🎯 **Visual Configuration**: Point and click instead of YAML editing
- 🔄 **Live Updates**: Changes apply immediately
- 👥 **Team Friendly**: Non-technical users can manage alerts/dashboards
- 🛡️ **Less Errors**: GUI validation prevents configuration mistakes
- 📱 **Mobile Friendly**: Manage from phones/tablets

---

## 🌐 Access URLs

After starting with `docker-compose up -d`:

| Service | URL | Purpose | Login |
|---------|-----|---------|-------|
| **Grafana** | `http://10.20.10.34:3000` | Main GUI for dashboards & alerts | admin/admin123 |
| **Prometheus** | `http://10.20.10.34:9090` | Metrics browser (troubleshooting) | None |
| **Uptime Kuma** | `http://10.20.10.34:3001` | Additional uptime monitoring | Set during first visit |

---

## 🎉 Success Indicators

### Immediate (After Step 3):
- ✅ Grafana accessible at port 3000
- ✅ Prometheus showing targets at port 9090
- ✅ Container metrics visible (cAdvisor)
- ✅ Network connectivity tests working

### After GUI Setup:
- ✅ All Proxmox VMs/LXCs visible in dashboards
- ✅ Custom alert rules triggering correctly
- ✅ Dashboard panels showing live data
- ✅ Log aggregation working in Grafana

**Most configuration happens through friendly web interfaces - not config file editing!** 🎯
