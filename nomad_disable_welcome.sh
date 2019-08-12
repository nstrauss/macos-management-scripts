#!/bin/zsh

defaults="/usr/bin/defaults"

"$defaults" write /Library/Preferences/com.trusourcelabs.NoMAD DontShowWelcome -bool TRUE
"$defaults" write /Library/Preferences/com.trusourcelabs.NoMAD DontShowWelcomeDefaultOn -bool TRUE
