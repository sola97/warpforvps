#!/bin/bash

# Ensure the variable is set before proceeding.
if [ -z "$myip" ]; then
    echo "Error: IP address variable 'myip' is not set." >&2
    exit 1
fi

# Convert the comma-separated list of IPs into an array.
IFS=',' read -r -a ips_array <<< "$myip"

# Initial sleep delay
sleep 5

# Infinite loop to monitor and change IP as needed.
while true; do
    # Fetch the current IP address using curl and filtering.
    ipnow=$(curl -s --socks5 127.0.0.1:40000 https://chat.openai.com/cdn-cgi/trace | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b')

    # Log the current IP
    echo "Current IP is $ipnow; excluded IPs are $myip"

    # Check if the current IP is in the excluded list
    found=false
    for ip in "${ips_array[@]}"; do
        if [[ "$ip" == "$ipnow" ]]; then
            found=true
            break
        fi
    done

    # Act based on whether the current IP was found in the list
    if [[ $found == false ]]; then
        echo "IP address meets the expected state, sleep 10 mins"
        sleep 600
    else
        echo "Start to change IP address"
        warp-cli --accept-tos disconnect
        sleep 3
        warp-cli --accept-tos connect
        sleep 1
    fi
done
