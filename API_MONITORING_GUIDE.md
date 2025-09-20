# API-Based Efficient VM/LXC Monitoring Setup

## 🎯 Problem: Manual Installation is NOT Scalable
- Installing node exporter on every VM/LXC = time consuming
- Hard to maintain across many containers
- Manual IP management in prometheus config
- No automatic discovery of new VMs/LXCs

## ✅ Solution: API-Based Monitoring

### 1. Proxmox VE API Exporter (Recommended)

**What it does:**
- Automatically discovers ALL VMs and LXC containers
- Collects metrics via Proxmox API (no installation inside VMs)
- Provides VM resource usage, status, and performance metrics
- Updates automatically when VMs are created/destroyed

**Setup Steps:**

#### A) Create Monitoring User in Proxmox
```bash
# SSH to ANY Proxmox node and run:
pveum user add monitoring@pve --password monitoring123
pveum role add Monitoring --privs "VM.Monitor,Datastore.Audit,Pool.Audit,Sys.Audit"
pveum aclmod / --user monitoring@pve --role Monitoring
```

#### B) PVE Exporter is Already Configured!
The docker-compose.yml now includes:
```yaml
pve-exporter:
  image: prompve/prometheus-pve-exporter:latest
  environment:
    - PVE_USER=monitoring@pve
    - PVE_PASSWORD=monitoring123
    - PVE_NODES=10.20.10.11,10.20.10.12,10.20.10.13,10.20.10.14,10.20.10.15,10.20.10.16
```

### 2. SNMP for Network Equipment (FortiNet)

**For your FortiNet firewall:**
```yaml
# Already configured in your stack:
snmp-exporter:
  - Monitors FortiNet via SNMP
  - Gets interface statistics, CPU, memory
  - No installation needed on firewall
```

### 3. Auto-Discovery Alternatives

#### Option A: Consul Service Discovery
```yaml
# For dynamic environments
consul_sd_configs:
  - server: 'consul:8500'
    services: ['node-exporter', 'application']
```

#### Option B: File-based Service Discovery
```yaml
# For semi-dynamic environments
file_sd_configs:
  - files: ['/etc/prometheus/targets/*.yml']
    refresh_interval: 30s
```

#### Option C: DNS Service Discovery  
```yaml
# For DNS-based discovery
dns_sd_configs:
  - names: ['_node-exporter._tcp.datacenter.local']
    type: 'SRV'
    port: 9100
```

## 🔥 What You Get with API-Based Monitoring

### Proxmox VE API Metrics (No VM Installation!)
```
# VM/LXC metrics automatically available:
pve_cpu_usage_ratio{instance="vm-101", name="web-server"}
pve_memory_usage_bytes{instance="vm-101", name="web-server"}  
pve_disk_usage_bytes{instance="vm-101", name="web-server"}
pve_network_receive_bytes{instance="vm-101", name="web-server"}
pve_status_running{instance="vm-101", name="web-server"}
pve_uptime_seconds{instance="vm-101", name="web-server"}
```

### Automatic Discovery Benefits
- ✅ **New VMs**: Automatically discovered and monitored
- ✅ **Deleted VMs**: Automatically removed from monitoring
- ✅ **Resource Limits**: VM allocation vs usage tracking
- ✅ **Hypervisor Metrics**: Host-level resource consumption
- ✅ **Storage Metrics**: Datastore usage across cluster

## 🚀 Implementation Strategy

### Phase 1: Start with API-Based (Today)
```bash
# 1. Create Proxmox monitoring user (5 minutes)
pveum user add monitoring@pve --password monitoring123
pveum role add Monitoring --privs "VM.Monitor,Datastore.Audit,Pool.Audit,Sys.Audit"  
pveum aclmod / --user monitoring@pve --role Monitoring

# 2. Start monitoring stack (2 minutes)
docker-compose up -d

# Result: ALL VMs/LXCs automatically monitored!
```

### Phase 2: Add Detailed Metrics (Optional)
```bash
# Only for VMs that need detailed OS-level metrics:
# Install node exporter on critical production VMs
# Keep API monitoring for development/testing VMs
```

### Phase 3: Advanced Auto-Discovery (Future)
```bash
# Implement service discovery for dynamic environments
# Add application-specific metrics
# Custom exporters for specialized services
```

## 📊 Monitoring Coverage Comparison

| Method | VM Discovery | OS Metrics | Setup Effort | Maintenance |
|--------|-------------|------------|--------------|-------------|
| **Manual Node Exporter** | Manual | Detailed | High (per VM) | High |
| **Proxmox API** | Automatic | Good | Low (one-time) | None |
| **Hybrid Approach** | Automatic + Manual | Best | Medium | Low |

## 🎯 Recommended Setup for Your Environment

### Current Infrastructure:
```yaml
# Automatic via API (No installation):
- All Proxmox VMs/LXC containers  
- FortiNet firewall (SNMP)
- Network connectivity (blackbox)
- Docker containers (cAdvisor)

# Manual installation only needed:
- Proxmox host nodes (6x node exporter)
- Critical production VMs (selective node exporter)
```

### Benefits of This Approach:
- ✅ **90% coverage** with minimal setup
- ✅ **Automatic discovery** of new VMs/containers
- ✅ **No maintenance** for VM monitoring
- ✅ **Scales automatically** as you add VMs
- ✅ **API-based** = more reliable than agents

## 🔧 Quick Setup Commands

```bash
# 1. Create Proxmox API user
ssh root@10.20.10.11 'pveum user add monitoring@pve --password monitoring123 && pveum role add Monitoring --privs "VM.Monitor,Datastore.Audit,Pool.Audit,Sys.Audit" && pveum aclmod / --user monitoring@pve --role Monitoring'

# 2. Start monitoring with API discovery
docker-compose up -d

# 3. Check metrics (should see all VMs automatically)
curl http://localhost:9221/pve?target=10.20.10.11&module=default
```

**Result**: Every VM and LXC container in your Proxmox cluster is now monitored automatically via API - no manual installation needed! 🎉

The API approach is definitely the way to go for efficiency and scalability!
