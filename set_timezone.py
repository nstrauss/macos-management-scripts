#!/usr/bin/python
# encoding: utf-8

"""
set_timezone.py
Use built-in tools to sync NTP server and set time zone. Default is to sync to
Apple's default time.apple.server. Zone can be changed with TIME_ZONE.

OS version code stolen mostly from Munki. 
https://github.com/munki/munki/blob/master/code/client/munkilib/osutils.py
"""

import platform
import subprocess
import sys

TIME_ZONE = "America/Chicago"


def get_os_version(only_major_minor=True, only_major=False, as_tuple=False):
    """Returns an OS version.
    Args:
      only_major_minor: Boolean. If True, only include major/minor versions.
      only_major: Boolean. If True, only include major version.
      as_tuple: Boolean. If True, return a tuple of ints, otherwise a string.
    """
    os_version_tuple = platform.mac_ver()[0].split(".")
    if only_major_minor:
        os_version_tuple = os_version_tuple[0:2]
    if only_major:
        os_version_tuple = os_version_tuple[1:2]
    if as_tuple:
        return tuple(map(int, os_version_tuple))
    else:
        return ".".join(os_version_tuple)


def sync_ntp(server, major_version):
    """Get major version, sync NTP using that version's tool."""
    if major_version <= 13:
        cmd = ["/usr/sbin/ntpdate", "-u", server]
    if major_version >= 14:
        cmd = ["/usr/bin/sntp", "-sS", server]

    try:
        subprocess.check_call(cmd, stdout=subprocess.PIPE)
    except subprocess.CalledProcessError as err:
        print(err)


def set_timezone(timezone):
    """Set system time zone."""
    cmd = ["/usr/sbin/systemsetup", "-settimezone", timezone]
    try:
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        out = proc.communicate()
        return out
    except Exception as err:
        print(err)


if __name__ == "__main__":
    major_version = int(get_os_version(only_major=True))
    sync_ntp("time.apple.com", major_version)
    set_timezone(TIME_ZONE)
