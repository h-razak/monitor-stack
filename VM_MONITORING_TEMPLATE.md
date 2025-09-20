# Complete Monitoring Coverage Guide

## What Gets Monitored Automatically? ✅

### Docker Containers (via cAdvisor)
- **ALL containers** on the monitoring host automatically
- CPU, memory, network, disk I/O usage
- Container start/stop events and health
- **No setup required** - works immediately when you start the stack!

### Network Infrastructure (via Blackbox Exporter)  
- Ping connectivity to all Proxmox nodes (10.20.10.11-16)
- FortiNet firewall connectivity (10.20.10.1)
- Web service availability (Proxmox web UI)
- External internet connectivity (8.8.8.8)
- **No setup required** - configured automatically!

### Logs (via Loki + Promtail)
- Docker container logs automatically collected
- System logs from `/var/log` automatically collected
- **No setup required** for monitoring host logs!

## What Needs Manual Setup? 🔧

### 1. Proxmox Node System Metrics (Priority 1)
**Install Node Exporter on each Proxmox node (10.20.10.11-16):**

```bash
# SSH to each Proxmox node and run:
curl -fsSL https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz | tar -xz
sudo cp node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/
sudo useradd --no-create-home --shell /bin/false node_exporter || true
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Create systemd service
sudo tee /etc/systemd/system/node_exporter.service > /dev/null << EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --web.listen-address=:9100

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
```

### 2. VM Monitoring (When You Create VMs)

#### Performance VMs (Future - VLAN 2: 10.0.2.x)
```bash
# Inside each performance VM, install node exporter:
# Same installation script as above

# Then uncomment in prometheus.yml:
# - job_name: 'performance-servers'
#   static_configs:
#     - targets:
#       - '10.0.2.10:9100'  # perf-vm-1
#       - '10.0.2.11:9100'  # perf-vm-2
```

#### Storage VMs (Future - VLAN 3: 10.0.3.x)  
```bash
# Inside each storage VM, install node exporter:
# Same installation script as above

# Then uncomment in prometheus.yml:
# - job_name: 'storage-servers'  
#   static_configs:
#     - targets:
#       - '10.0.3.20:9100'  # storage-vm-1
#       - '10.0.3.21:9100'  # storage-vm-2
```

### 3. LXC Containers on Proxmox
```bash
# Inside each LXC container you want to monitor:
# Install node exporter (same script as above)

# Add to prometheus.yml:
# - job_name: 'lxc-containers'
#   static_configs:
#     - targets: ['container-ip:9100']
```

## Monitoring Coverage Summary

| Component | Auto-Monitored | Metrics Available |
|-----------|---------------|------------------|
| **Docker Containers** | ✅ Yes | CPU, memory, network, disk I/O, lifecycle events |
| **Container Logs** | ✅ Yes | All stdout/stderr logs via Loki |
| **Network Connectivity** | ✅ Yes | Ping tests, web service availability |
| **Prometheus Stack** | ✅ Yes | All service health and performance |
| **Proxmox Nodes** | 🔧 Node Exporter | Full system metrics when installed |
| **Future VMs** | 🔧 Node Exporter | Full system metrics when installed |
| **LXC Containers** | 🔧 Node Exporter | Full system metrics when installed |

## Quick Start Phases

### Phase 1: Start Now (5 minutes)
```bash
cd /home/uxrdxt/code-server/monitoring
docker-compose up -d
```
**Result**: Container, network, and log monitoring active immediately!

### Phase 2: Full Infrastructure (30 minutes)  
```bash
# Install node exporter on all 6 Proxmox nodes
for ip in 10.20.10.{11..16}; do
  ssh root@$ip "curl -fsSL [installation-script-url] | bash"
done
```
**Result**: Complete datacenter infrastructure monitoring!

### Phase 3: VMs (As Needed)
- Install node exporter on each VM as you create them
- Add VM IPs to prometheus.yml
- Restart Prometheus to pick up new targets

## Container Monitoring Deep Dive

### What cAdvisor Monitors Automatically:
- **Resource Usage**: Real-time CPU, memory, network, disk metrics
- **Container Lifecycle**: Start, stop, restart events  
- **Performance**: Throughput, latency, error rates
- **Health**: Container status and resource limits
- **Historical Data**: Trends and capacity planning

### VM Containers vs Docker Containers:
- **Docker Containers**: Monitored by cAdvisor (automatic)
- **VMs**: Need individual node exporter installation
- **LXC Containers**: Need individual node exporter installation

## The Bottom Line

**Start your monitoring stack right now** - you'll immediately get:
- All Docker container monitoring
- Network connectivity monitoring  
- Log aggregation
- Infrastructure health dashboards

Then add node exporters to get complete system metrics as needed. The beauty is that container monitoring works perfectly without any additional setup!
