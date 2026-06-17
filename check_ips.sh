#!/bin/bash

echo "==================================="
echo "Nginx Proxy IP Address Analysis"
echo "==================================="

echo "Collecting Nginx proxy logs..."
docker compose logs nginx_proxy > /tmp/nginx_logs.txt 2>&1

echo ""
echo "Analyzing IP addresses in access logs..."
# Extract only lines that start with an actual IP address (checking $3 field)
# Format: nginx_proxy  | IP_ADDRESS - - [date] "request" status size "referer" "user-agent" -
grep -E '^[a-z_]+  \| [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' /tmp/nginx_logs.txt | awk '{print $3}' | \
sort | uniq -c | sort -nr > /tmp/ip_analysis.txt

echo ""
echo "Top 10 most frequent IP addresses (potential scanners):"
cat /tmp/ip_analysis.txt | head -10

echo ""
echo "==================================="
echo "IP Address Analysis Details"
echo "==================================="
echo "Total unique IP addresses: $(grep -E '^[a-z_]+  \| [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' /tmp/nginx_logs.txt | awk '{print $3}' | sort -u | wc -l)"
echo "Total log entries with IP addresses: $(grep -E '^[a-z_]+  \| [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' /tmp/nginx_logs.txt | wc -l)"

echo ""
echo "Top 20 IP addresses by frequency:"
cat /tmp/ip_analysis.txt

echo ""
echo "==================================="
echo "Log file saved to: /tmp/nginx_logs.txt"
echo "IP analysis saved to: /tmp/ip_analysis.txt"
echo "==================================="