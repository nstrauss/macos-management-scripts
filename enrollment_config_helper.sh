#!/bin/zsh

timestamp () {
    echo $(date "+%a %h %d %H:%M:%S")
}

log_file="/var/tmp/mds_dep_enroll.log"

# Check if script running as root
if [[ $EUID != 0 ]] ; then
    echo $(timestamp) "Failed to run. Must run as root or with sudo." >> "$log_file"
    exit 1
fi

echo $(timestamp) "Starting enrollment configuration helper..." >> "$log_file"
echo $(timestamp) "Waiting for setup assistant..." >> "$log_file"

# Only start script once Setup Assistant has launched
until [[ $(pgrep -x "Setup Assistant") ]]; do
    wait
done

echo $(timestamp) "Setup assistant is up. Getting enrollment configuration..." >> "$log_file"

# Run enrollment configuration check
for i in {1..3}; do
    sleep 5
    profiles renew -type enrollment &>> "$log_file"
    if [[ $? == "0" ]]; then
        echo $(timestamp) "Got enrollment configuration." >> "$log_file"
        sleep 2
        profiles show -type enrollment &>> "$log_file" 
        
        # Delete launch daemon
        rm -rf /Library/LaunchDaemons/com.isd720.enrollment-config-helper.plist
        break
    else
        echo $(timestamp) "Failed to get enrollment configuration - attempt ${i}" >> "$log_file"
    fi
done

