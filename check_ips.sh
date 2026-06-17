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
sort | uniq -c | sort -nr > /tmp/ip_count.txt

echo ""
echo "Top 10 most frequent IP addresses (potential scanners):"
cat /tmp/ip_count.txt | head -10

# Create enhanced analysis with country lookup
echo ""
echo "==================================="
echo "Enhanced IP Analysis with Country Lookup"
echo "==================================="
echo "IP Address         Request Count    Country" > /tmp/ip_analysis.txt
echo "-----------------------------------------------" >> /tmp/ip_analysis.txt

while read count ip; do
    # Get country using ipinfo.io (free service, rate limits apply)
    response=$(curl -s --max-time 5 "https://ipinfo.io/${ip}/country" 2>/dev/null)
    # Check if response is valid (should be 2-letter country code) or error
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
echo "IP Address Analysis Details"
echo "==================================="
echo "Total unique IP addresses: $(wc -l < /tmp/ip_count.txt)"
echo "Total log entries with IP addresses: $(grep -E '^[a-z_]+  \| [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' /tmp/nginx_logs.txt | wc -l)"

echo ""
echo "Full IP analysis saved to: /tmp/ip_analysis.txt"
echo "Raw logs saved to: /tmp/nginx_logs.txt"
echo "==================================="