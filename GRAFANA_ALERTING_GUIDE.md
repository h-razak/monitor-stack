# Grafana Native Alerting Setup Guide

## Overview
Your monitoring stack now uses **Grafana's built-in alerting system** instead of a separate AlertManager. This provides a unified GUI-based approach for all alert configuration.

## Quick Setup Steps

### 1. Access Grafana
- URL: `http://10.20.10.34:3000`
- Username: `admin`
- Password: `admin123`

### 2. Configure Alert Notifications (Contact Points)

1. Go to **Alerting** → **Contact Points** in the left menu
2. Click **+ Add contact point**
3. Configure your preferred notification method:

#### Email Notifications
```
Name: datacenter-email
Type: Email
Settings:
  - Addresses: your-email@domain.com
  - Subject: [DATACENTER ALERT] {{ .CommonLabels.alertname }}
```

#### Slack Notifications
```
Name: datacenter-slack
Type: Slack
Settings:
  - Webhook URL: your-slack-webhook-url
  - Channel: #alerts
  - Title: Datacenter Alert
```

#### Microsoft Teams
```
Name: datacenter-teams
Type: Microsoft Teams
Settings:
  - Webhook URL: your-teams-webhook-url
```

### 3. Create Alert Rules

Navigate to **Alerting** → **Alert Rules** → **+ New alert rule**

#### Example: High CPU Usage Alert
```
Query: avg(100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100))
Condition: IS ABOVE 80
Evaluation: Every 1m for 5m
Label: severity=warning, server_type=proxmox
Annotation: Summary="High CPU usage on {{ $labels.instance }}"
```

#### Example: Server Down Alert  
```
Query: up{job="proxmox-nodes"}
Condition: IS BELOW 1
Evaluation: Every 30s for 2m
Label: severity=critical, server_type=proxmox
Annotation: Summary="Server {{ $labels.instance }} is down"
```

#### Example: Disk Space Alert
```
Query: (node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100
Condition: IS BELOW 10
Evaluation: Every 2m for 5m
Label: severity=warning, server_type=storage
Annotation: Summary="Low disk space on {{ $labels.instance }}: {{ $value }}% free"
```

#### Example: Network Connectivity Alert
```
Query: probe_success{job="network-ping-check"}
Condition: IS BELOW 1
Evaluation: Every 1m for 3m
Label: severity=critical, check_type=network
Annotation: Summary="Network connectivity failed to {{ $labels.instance }}"
```

### 4. Create Notification Policies

1. Go to **Alerting** → **Notification policies**
2. Edit the default policy or create new ones:

#### Default Policy
```
Receiver: datacenter-email
Group by: alertname
Group wait: 10s
Group interval: 5m
Repeat interval: 12h
```

#### Critical Alerts Policy
```
Matchers: severity = critical
Receiver: datacenter-slack
Group wait: 0s
Group interval: 1m
Repeat interval: 1h
```

### 5. Test Your Alerts

1. Go to **Alerting** → **Alert Rules**
2. Find your rule and click **...** → **Test rule**
3. Verify the query returns expected results
4. Save and wait for evaluation

## Pre-configured Monitoring Targets

Your system is already configured to monitor:

### Proxmox Cluster (10.20.10.11-16)
- System metrics (CPU, memory, disk, network)
- Service availability 
- Web interface health

### Network Infrastructure
- FortiNet firewall (10.20.10.1)
- Inter-network connectivity
- External internet access (8.8.8.8)

### Monitoring Stack Health
- Prometheus, Grafana, exporters
- Container health and resources

## Common Alert Examples

### Server Health
- CPU usage > 80%
- Memory usage > 85%
- Disk space < 10%
- Load average > number of CPUs

### Network Monitoring  
- Ping failures
- Web service unavailable
- High network latency

### Infrastructure
- Container restarts
- Service down
- Certificate expiration

## Best Practices

1. **Start Simple**: Begin with basic up/down alerts
2. **Group Alerts**: Use labels to organize alerts by severity/team
3. **Avoid Alert Fatigue**: Set appropriate thresholds and grouping
4. **Test Regularly**: Verify alerts work during maintenance windows
5. **Document Runbooks**: Add links to resolution procedures in annotations

## GUI Navigation Tips

- **Dashboards** → View real-time metrics and graphs
- **Alerting** → Configure all alert rules and notifications  
- **Explore** → Query metrics directly for troubleshooting
- **Configuration** → Manage data sources and settings

All alerting is now managed through Grafana's web interface - no configuration files needed!
