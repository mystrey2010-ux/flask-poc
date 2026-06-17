#!/bin/bash

echo "==================================="
echo "Nginx Proxy IP Address Analysis"
echo "==================================="

# Check if docker compose is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

echo "Collecting Nginx proxy logs..."
docker compose logs nginx_proxy > /tmp/nginx_logs.txt 2>&1

echo ""
echo "Analyzing IP addresses in access logs..."
# Extract IP addresses from log lines (field after service prefix)
grep -E '^[a-z_]+  \| [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' /tmp/nginx_logs.txt | awk '{print $3}' | \
sort | uniq -c | sort -nr > /tmp/ip_count.txt

echo ""
echo "Top 10 most frequent IP addresses:"
printf "%-20s %-15s %s\n" "IP Address" "Request Count" "Country"
printf "%-20s %-15s %s\n" "---------------" "-------------" "-------"
head -10 /tmp/ip_count.txt | while read count ip; do
    response=$(curl -s --max-time 3 "https://ipinfo.io/${ip}/country" 2>/dev/null)
    if [[ -z "$response" ]] || [[ "$response" == "{"* ]]; then
        country="Unknown"
    else
        country="$response"
    fi
    printf "%-20s %-15s %s\n" "$ip" "$count" "$country"
done

# Create enhanced analysis with country lookup
echo ""
echo "==================================="
echo "Full IP Analysis with Country Lookup"
echo "==================================="
echo "IP Address         Request Count    Country" > /tmp/ip_analysis.txt
echo "-----------------------------------------------" >> /tmp/ip_analysis.txt

while read count ip; do
    response=$(curl -s --max-time 3 "https://ipinfo.io/${ip}/country" 2>/dev/null)
    if [[ -z "$response" ]] || [[ "$response" == "{"* ]]; then
        country="Unknown"
    else
        country="$response"
    fi
    printf "%-20s %-15s %s\n" "$ip" "$count" "$country" >> /tmp/ip_analysis.txt
done < /tmp/ip_count.txt

cat /tmp/ip_analysis.txt

echo ""
echo "==================================="
echo "Security Analysis Summary"
echo "==================================="
echo "Total unique IP addresses: $(wc -l < /tmp/ip_count.txt)"
echo "Total log entries with IP addresses: $(grep -E '^[a-z_]+  \| [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' /tmp/nginx_logs.txt | wc -l)"
echo ""
echo "Log file saved to: /tmp/nginx_logs.txt"
echo "IP analysis saved to: /tmp/ip_analysis.txt"
echo "==================================="