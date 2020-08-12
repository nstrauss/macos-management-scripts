#!/bin/zsh

# Configurable retries. How many retries in a cycle, how many total cycles.
retries="3"
cycles="10"

# Log paths
log_file="/var/tmp/mds_dep_enroll.log"
pm_data="/var/tmp/pm_data.plist"

timestamp () {
    echo $(date "+%a %h %d %H:%M:%S")
}

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

echo $(timestamp) "Setup assistant is up." >> "$log_file"

# Append OS info   
os_version=$(defaults read /System/Library/CoreServices/SystemVersion.plist ProductVersion)
os_build=$(defaults read /System/Library/CoreServices/SystemVersion.plist ProductBuildVersion)
echo $(timestamp) "OS version: ${os_version}" >> "$log_file"
echo $(timestamp) "OS build: ${os_build}" >> "$log_file"

# Run enrollment configuration check
config_status=""
for x in {1.."$cycles"}; do
    echo $(timestamp) "Starting cycle ${x}..." >> "$log_file"

    # Get power metrics data and append thermal data
    echo $(timestamp) "Checking power metrics..." >> "$log_file"
    powermetrics -i 1 -n 1 --samplers smc,thermal --format plist > "$pm_data"
    cpu_thermal_level=$(/usr/libexec/PlistBuddy -c "print 'smc':cpu_thermal_level" ${pm_data})
    io_thermal_level=$(/usr/libexec/PlistBuddy -c "print 'smc':io_thermal_level" ${pm_data})
    fan_rpm=$(/usr/libexec/PlistBuddy -c "print 'smc':fan" ${pm_data})
    cpu_die_temp=$(/usr/libexec/PlistBuddy -c "print 'smc':cpu_die" ${pm_data})
    thermal_pressure=$(defaults read ${pm_data} thermal_pressure)
    echo $(timestamp) "CPU thermal level: ${cpu_thermal_level}" >> "$log_file"
    echo $(timestamp) "IO thermal level: ${io_thermal_level}" >> "$log_file"
    echo $(timestamp) "Fan RPM: ${fan_rpm}" >> "$log_file"
    echo $(timestamp) "CPU die temp: ${cpu_die_temp} C" >> "$log_file"
    echo $(timestamp) "Thermal pressure: ${thermal_pressure}" >> "$log_file"

    # Attempt to get enrollment configuration
    echo $(timestamp) "Getting enrollment configuration..." >> "$log_file"
    for i in {1.."$retries"}; do
        sleep 5
        profiles renew -type enrollment &>> "$log_file"
        if [[ $? == "0" ]]; then
            echo $(timestamp) "Got enrollment configuration..." >> "$log_file"
            sleep 2
            profiles show -type enrollment &>> "$log_file" 
            
            # Delete launch daemon
            rm -rf /Library/LaunchDaemons/com.isd720.enrollment-config-helper.plist

            # Mark config status as succeeded
            config_status="success"
            break
        else
            echo $(timestamp) "Failed to get enrollment configuration - attempt ${i}" >> "$log_file"
        fi
    done
    if [[ "$config_status" = "success" ]]; then
        break
    else
        if [[ "$x" = "$cycles" ]]; then
            echo $(timestamp) "*** Gone through ${x} failed cycles. Stop here. Shut down Mac, let it cool for 10 minutes, and try again." >> "$log_file"
            exit 1
        else
            echo $(timestamp) "Cycle ${x} - all attempts failed. Waiting 1 minute for Mac to cool down before trying again." >> "$log_file"
            sleep 60
        fi
    fi
done
