#!/usr/bin/python
# encoding: utf-8

"""
set_finder_prefs.py
Set user level finder preferences using defaults for values listed in the
provided dictionary. User must be logged in.
"""

import subprocess

# pylint: disable=E0611
from SystemConfiguration import SCDynamicStoreCopyConsoleUser


FINDER_PREFS = {
    "ShowStatusBar": {"type": "-bool", "value": "TRUE"},
    "ShowPathBar": {"type": "-bool", "value": "TRUE"},
    "FXPreferredViewStyle": {"type": "-string", "value": "Nlsv"},
}


def get_currentuser():
    """Uses Apple's SystemConfiguration framework to get the current
    console user. Stolen from munki code.
    https://github.com/munki/munki/blob/master/code/client/launchapp"""
    cfuser = SCDynamicStoreCopyConsoleUser(None, None, None)
    return cfuser[0]


def set_pref(username, pref, data_type, value):
    cmd = [
        "/usr/bin/sudo",
        "-u",
        username,
        "/usr/bin/defaults",
        "write",
        "com.apple.finder",
        pref,
        data_type,
        value,
    ]
    subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)


if __name__ == "__main__":
    user = get_currentuser()
    for pref in FINDER_PREFS:
        data_type = FINDER_PREFS[pref]["type"]
        value = FINDER_PREFS[pref]["value"]
        set_pref(user, pref, data_type, value)
