#!/bin/zsh
#
# Mac Mobile Filter removal script
# Copyright Lightspeed Systems 2013
# Modified by Nathaniel Strauss 2020 because yikes
#

if [[ $EUID != 0 ]] ; then
    echo "Must be run as root or via sudo"
    exit 1
fi

# Unload launch daemons
launchctl unload /Library/LaunchDaemons/com.lightspeedsystems.lsproxy.plist > /dev/null 2>&1
launchctl unload /Library/LaunchDaemons/com.lightspeedsystems.mobilefilter.plist > /dev/null 2>&1
launchctl unload /Library/LaunchDaemons/com.lightspeedsystems.proxyforce.plist > /dev/null 2>&1
launchctl unload /Library/LaunchDaemons/com.lightspeedsystems.smartagentjs.plist > /dev/null 2>&1

# Delete launch daemons
rm -rf /Library/LaunchDaemons/com.lightspeedsystems.lsproxy.plist > /dev/null 2>&1
rm -rf /Library/LaunchDaemons/com.lightspeedsystems.mobilefilter.plist > /dev/null 2>&1
rm -rf /Library/LaunchDaemons/com.lightspeedsystems.proxyforce.plist > /dev/null 2>&1
rm -rf /Library/LaunchDaemons/com.lightspeedsystems.smartagentjs.plist > /dev/null 2>&1

# Unload agent associated processes and kernel extension
/usr/local/bin/cagen unload > /dev/null 2>&1
/usr/local/bin/mobilefilter -unload > /dev/null 2>&1
/usr/local/bin/proxyforce unload > /dev/null 2>&1
/sbin/kextunload /Library/Extensions/MobileFilterKext.kext

# Remove smart agent files
rm /usr/local/bin/cagen > /dev/null 2>&1
rm /usr/local/etc/ca_key.pem > /dev/null 2>&1
rm /usr/local/etc/ca.pem > /dev/null 2>&1
rm /usr/local/bin/com.lightspeedsystems.restartservices.plist > /dev/null 2>&1
rm /usr/local/bin/LightspeedRelaySmartAgentCopyrights.rtf > /dev/null 2>&1
rm /usr/local/bin/lsproxy > /dev/null 2>&1
rm /usr/local/bin/makeca > /dev/null 2>&1
rm /usr/local/bin/mobilefilter > /dev/null 2>&1
rm /usr/local/bin/mobilefilterupdatekext > /dev/null 2>&1
rm /usr/local/bin/mobilefilterupdate > /dev/null 2>&1
rm /usr/local/bin/mobilefilterupdatecopy > /dev/null 2>&1
rm /usr/local/bin/proxyforce > /dev/null 2>&1
rm -rf /usr/local/bin/SmartAgentJS > /dev/null 2>&1
rm /usr/local/etc/ca_key.pem > /dev/null 2>&1
rm /usr/local/etc/ca.pem > /dev/null 2>&1
rm /usr/local/etc/localhost_key.pem > /dev/null 2>&1
rm /usr/local/etc/localhost.pem > /dev/null 2>&1
rm /usr/local/etc/SmartAgentUpdate.dmg > /dev/null 2>&1

# Remove kext
rm -rf /Library/Extensions/MobileFilterKext.kext > /dev/null 2>&1
