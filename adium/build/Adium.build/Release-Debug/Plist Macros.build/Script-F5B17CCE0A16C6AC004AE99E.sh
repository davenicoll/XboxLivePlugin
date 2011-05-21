#!/bin/sh
PATH=$PATH:/usr/local/bin:/usr/bin:/sw/bin:/opt/local/bin
buildid="`hg parent --template {node\|short}`"

echo "#define BUILDID $buildid" > $SCRIPT_OUTPUT_FILE_0
echo "#define BUILDDATE `date +%s`" >> $SCRIPT_OUTPUT_FILE_0
echo "#define WHOAMI `whoami`" >> $SCRIPT_OUTPUT_FILE_0

# Delete the intermediate Info.plist so that Xcode re-preprocesses the Info.plist with our updated macros.
# Use -f because after a clean build, this file doesn't exist yet, so a plain rm would fail and stop the build.
rm -f "${CONFIGURATION_TEMP_DIR}/Adium.build/Preprocessed-Info.plist"

