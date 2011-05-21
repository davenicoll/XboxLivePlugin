#!/bin/sh
#############################################################################################
# Set framework bundles to have their executables' dates, thereby letting Xcode suck less.  #
#############################################################################################
touch "$SRCROOT/Frameworks/libpurple.framework"
touch "$SRCROOT/Frameworks/Growl.framework"
touch "$SRCROOT/Frameworks/LMX.framework"
touch "$SRCROOT/Frameworks/PSMTabBarControl.framework"
touch "$SRCROOT/Frameworks/Sparkle.framework"
touch "$SRCROOT/Frameworks/libotr.framework"

