# 🔑 Proxmox API User Setup Guide (GUI Method)

## 🎯 Overview
This guide shows you how to create a monitoring user in Proxmox through the web interface. This user will allow the monitoring stack to automatically discover and monitor all VMs and LXC containers.

## 📋 Prerequisites
- Access to any Proxmox node web interface
- Admin privileges in Proxmox
- 5 minutes of time

## 🌐 Step 1: Access Proxmox Web Interface

Open your browser and go to **any** of your Proxmox nodes:
- `https://10.20.10.11:8006` (or any node from .11 to .16)
- Login with your admin credentials
- Accept SSL certificate warning if prompted

## 👤 Step 2: Create Monitoring User

### Navigate to User Management
1. In the left sidebar, click **"Datacenter"**
2. Expand **"Permissions"**
3. Click **"Users"**

### Add New User
1. Click the **"Add"** button at the top
2. Fill in the user details:

```
User name: monitoring
Realm: Proxmox VE authentication server (pve)
Password: monitoring123
Confirm Password: monitoring123
Email: (optional)
First Name: Monitoring
Last Name: User
Comment: Prometheus monitoring system user
Enabled: ✅ (checked)
Expire: Never
```

3. Click **"Add"** to create the user

### ✅ Result
User `monitoring@pve` is now created and visible in the user list.

## 🔐 Step 3: Create Monitoring Role

### Navigate to Role Management
1. Still in **"Datacenter"** → **"Permissions"**
2. Click **"Roles"**

### Create Custom Role
1. Click the **"Create"** button
2. Fill in role details:

```
Name: PrometheusMonitoring
```

3. **Select Privileges** (check these boxes):
   - **Datastore**:
     - ✅ `Datastore.Audit` - View datastore status
   - **Pool**:
     - ✅ `Pool.Audit` - View pool information
   - **System**:
     - ✅ `Sys.Audit` - View system status and logs
   - **Virtual Machine**:
     - ✅ `VM.Audit` - View VM configuration and status
     - ✅ `VM.Monitor` - Access VM monitor (console)

4. Click **"Create"** to save the role

### ✅ Result
Role `PrometheusMonitoring` now appears in the roles list with appropriate monitoring permissions.

## 🎯 Step 4: Assign Permissions

### Navigate to Permissions
1. Still in **"Datacenter"** → **"Permissions"**
2. Click **"Permissions"** (the main permissions view)

### Add User Permission
1. Click **"Add"** → **"User Permission"**
2. Configure the permission:

```
Path: / 
User: monitoring@pve
Role: PrometheusMonitoring
Propagate: ✅ (checked - very important!)
```

### Important Notes:
- **Path `/`**: Gives access to entire datacenter
- **Propagate ✅**: Ensures permissions apply to all nodes, VMs, and containers
- **Role**: Uses the custom role we just created

3. Click **"Add"** to apply the permission

### ✅ Result
The monitoring user now has read-only access to monitor the entire Proxmox cluster.

## 🔍 Step 5: Verify Setup

### Check User List
1. Go to **"Datacenter"** → **"Permissions"** → **"Users"**
2. Verify `monitoring@pve` appears in the list
3. Status should show as **"enabled"**

### Check Permissions
1. Go to **"Datacenter"** → **"Permissions"** → **"Permissions"**
2. Verify entry showing:
   - **Path**: `/`
   - **User**: `monitoring@pve`
   - **Role**: `PrometheusMonitoring`
   - **Propagate**: `Yes`

### Test API Access (Optional)
You can test the API user by running this command from your monitoring server:

```bash
# Test API connection (replace 10.20.10.11 with any of your Proxmox nodes)
curl -k -d "username=monitoring@pve&password=monitoring123" \
  https://10.20.10.11:8006/api2/json/access/ticket
```

**Expected Result**: Should return a JSON response with authentication ticket (not an error).

## 🎉 Step 6: Update Your .env File

Now update your monitoring configuration in `.env`:

```bash
# Proxmox API credentials (matches what you created above)
PVE_API_USER=monitoring@pve
PVE_API_PASSWORD=monitoring123
PVE_VERIFY_SSL=false
```

## 🚀 Step 7: Start Monitoring

With the API user configured, you can now start your monitoring stack:

```bash
cd /path/to/monitoring
docker-compose up -d
```

## 🔍 Verification Steps

### Check PVE Exporter Logs
```bash
docker logs pve-exporter
```
**Expected**: No authentication errors, successful connection messages.

### Test Metrics Endpoint
```bash
curl "http://localhost:9221/pve?target=10.20.10.11&module=default"
```
**Expected**: Prometheus metrics output showing VM and host data.

### Grafana Data Sources
1. Open Grafana: `http://10.20.10.34:3000`
2. Login: admin / admin123
3. Go to **Configuration** → **Data Sources**
4. **Expected**: Prometheus data source showing "Working" status

## 🛠️ Troubleshooting

### Common Issues:

#### "Authentication Failed"
- ✅ **Check**: Username is exactly `monitoring@pve` (include @pve)
- ✅ **Check**: Password matches what you set in Proxmox
- ✅ **Check**: User is enabled in Proxmox GUI

#### "Permission Denied"
- ✅ **Check**: Role includes `VM.Monitor` and `VM.Audit` privileges
- ✅ **Check**: Permission is applied to path `/` with Propagate enabled
- ✅ **Check**: Role assignment shows in Permissions list

#### "Connection Refused"
- ✅ **Check**: Proxmox nodes are accessible from monitoring server
- ✅ **Check**: Firewall allows access to port 8006
- ✅ **Check**: Node IPs are correct in .env file

#### "SSL/TLS Errors"
- ✅ **Set**: `PVE_VERIFY_SSL=false` in .env file
- ✅ **Check**: Using `https://` URLs for Proxmox access

## 📝 Security Notes

### What This User CAN Do:
- ✅ Read VM/LXC status and metrics
- ✅ View resource usage and performance data
- ✅ Access monitoring APIs
- ✅ Read configuration information

### What This User CANNOT Do:
- ❌ Start/stop/modify VMs or containers
- ❌ Change Proxmox configuration
- ❌ Access VM consoles or content
- ❌ Create/delete resources
- ❌ Modify user permissions

This is a **read-only monitoring user** with minimal required permissions for safe operation.

## 🎯 Summary

You've successfully created:
1. ✅ **Monitoring User**: `monitoring@pve` with secure password
2. ✅ **Custom Role**: `PrometheusMonitoring` with minimal required permissions
3. ✅ **Datacenter Access**: Full cluster visibility with read-only access
4. ✅ **API Integration**: Ready for automatic VM/LXC discovery

Your monitoring stack can now automatically discover and monitor all current and future VMs/LXCs without any manual configuration! 🎉
