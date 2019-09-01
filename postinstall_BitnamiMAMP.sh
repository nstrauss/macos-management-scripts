#!/bin/zsh

# User variables
logged_in_user=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')

# Installer variables
base_pass="shakopeesabers"
install_dir="/Users/${logged_in_user}/Applications/mampstack"

# Run installer
sudo -u "$logged_in_user" /private/tmp/MAMP.app/Contents/MacOS/osx-x86_64 \
--mode unattended \
--prefix "$install_dir" \
--base_password "$base_pass" \
--launch_cloud "0"

# Create symlink to user desktop
ln -s "$install_dir"/manager-osx.app "/Users/${logged_in_user}/Desktop/Application Manager.app"

# Clean up
rm -rf /private/tmp/MAMP.app