#!/bin/bash

# Only allow local account login
dseditgroup -o create -q com.apple.access_loginwindow
dseditgroup -o edit -n /Local/Default -a "localaccounts" -t group com.apple.access_loginwindow

exit $?