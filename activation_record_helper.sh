#!/bin/zsh

log_file="/var/tmp/mds_dep_enroll.log"

# Check if script running as root
echo "Running as user ID ${EUID}" >> "$log_file"

# Only start script once Setup Assistant has launched
until [[ $(pgrep -x "Setup Assistant") ]]; do
    wait
done

sleep 10

# Run enrollment profile check
for i in {1..3}; do
    sleep 5
    profiles renew -type enrollment &>> "$log_file"
    if [[ $? == "0" ]]; then
        echo "Got enrollment configuration..." >> "$log_file"
        sleep 5
        profiles show -type enrollment &>> "$log_file"
        
        # Delete launch daemon
        rm -rf /Library/LaunchDaemons/com.isd720.activation-record-helper.plist
        break
    else
        profiles show -type enrollment &>> "$log_file"
        echo "Failed to get enrollment configuration attempt ${i}" >> "$log_file"
    fi
done

