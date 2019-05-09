#!/usr/bin/python
# encoding: utf-8

# original author:    Matthew Warren
#                     @haircut on #macadmins slack
# created:            2018-04-20
# modified:           2018-04-21
# edited:             Nathaniel Strauss
# modified:           2019-05-08
# https://gist.github.com/haircut/b5d5bea915a58c9b61160c857e7a08a2

"""
Forget saved SSIDs with whitelisting.

This script removes ALL saved SSIDs on a Mac except for those configured in a
whitelist – see SSID_WHITELIST variable below.

If you configure Wi-Fi via profile you must exclude those configured SSIDs. 
The networksetup binary does not care about your profiles!
"""

import subprocess
import sys

# pylint: disable=E0611
from SystemConfiguration import (
    SCNetworkInterfaceCopyAll,
    SCNetworkInterfaceGetBSDName,
    SCNetworkInterfaceGetHardwareAddressString,
    SCNetworkInterfaceGetLocalizedDisplayName,
)

SSID_WHITELIST = ["WirelessSSID1", "WirelessSSID2"]


def get_wifi_interface():
    """Returns the name of the wifi interface."""
    network_interfaces = SCNetworkInterfaceCopyAll()
    interfaces = {}
    for interface in network_interfaces:
        interfaces[SCNetworkInterfaceGetLocalizedDisplayName(interface)] = (
            SCNetworkInterfaceGetBSDName(interface),
            SCNetworkInterfaceGetHardwareAddressString(interface),
        )
    wifi_interface = None
    try:
        wifi_interface = interfaces["Wi-Fi"][0]
    except KeyError:
        pass
    return wifi_interface


def get_ssids(interface):
    """Returns a list of saved SSIDs for the provided interface."""
    cmd = ["networksetup", "-listpreferredwirelessnetworks", interface]
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output, _ = proc.communicate()
    return [item.strip() for item in output.splitlines()[1:]]


def remove_ssid(ssid, interface):
    """Removes the passed SSID from the preferred SSID list on the passed 
    interface."""
    cmd = ["networksetup", "-removepreferredwirelessnetwork", interface, ssid]
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output, _ = proc.communicate()
    return True if proc.returncode == 0 else False


def main():
    """Main."""
    interface = get_wifi_interface()
    # Exit cleanly on Macs with no wireless interface
    if interface is None:
        print("No Wi-Fi interface. Exiting.")
        sys.exit(0)

    # Remove SSIDs
    ssids = get_ssids(interface)
    for ssid in ssids:
        if ssid not in SSID_WHITELIST:
            if remove_ssid(ssid, interface):
                print("Removed SSID %s" % ssid)
            else:
                print("Unable to remove SSID %s" % ssid)


if __name__ == "__main__":
    main()
