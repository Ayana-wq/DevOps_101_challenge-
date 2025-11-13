#!/bin/bash

# ----------------------------
# EC2 Custom Metrics to CloudWatch
# Collects: Memory, CPU, and Disk usage
# ----------------------------
# Make this file executable:
#   sudo chmod +x metrics.sh
# ----------------------------------

# === Step 1. Get IMDSv2 Token (valid for 60 seconds)
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
-H "X-aws-ec2-metadata-token-ttl-seconds: 60" -s)

# === Step 2. Fetch Instance ID using the token
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
-s http://169.254.169.254/latest/meta-data/instance-id)

# === Step 3. Get Region (from instance metadata)
REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
-s http://169.254.169.254/latest/meta-data/placement/region)

# === Step 4. Calculate Metrics ===

# Memory usage (%)
MEMORY_USAGE=$(free | awk '/Mem/{printf("%d", ($2-$7)/$2*100)}')

# CPU usage (% over 1 second sample)
CPU_USAGE=$(top -bn2 | grep "Cpu(s)" | \
tail -n 1 | awk '{print 100 - $8}')

# Disk usage (% for /)
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

# === Step 5. Push metrics to CloudWatch ===
aws cloudwatch put-metric-data \
--region "$REGION" \
--namespace "EC2 Custom Metrics" \
--metric-name "MemoryUsage" \
--value "$MEMORY_USAGE" \
--unit "Percent" \
--dimensions "Name=InstanceId,Value=$INSTANCE_ID"

aws cloudwatch put-metric-data \
--region "$REGION" \
--namespace "EC2 Custom Metrics" \
--metric-name "CPUUsage" \
--value "$CPU_USAGE" \
--unit "Percent" \
--dimensions "Name=InstanceId,Value=$INSTANCE_ID"

aws cloudwatch put-metric-data \
--region "$REGION" \
--namespace "EC2 Custom Metrics" \
--metric-name "DiskUsage" \
--value "$DISK_USAGE" \
--unit "Percent" \
--dimensions "Name=InstanceId,Value=$INSTANCE_ID"

# === Step 6. Optional: Log results ===
echo "$(date '+%Y-%m-%d %H:%M:%S') | Instance: $INSTANCE_ID | Mem: ${MEMORY_USAGE}% | CPU: ${CPU_USAGE}% | Disk: ${DISK_USAGE}%" >> /var/log/metrics.log
