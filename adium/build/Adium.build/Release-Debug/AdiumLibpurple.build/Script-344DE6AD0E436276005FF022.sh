#!/bin/sh
# otool -L "$SCRIPT_INPUT_FILE_0" | grep libpurple.framework | 
# install_name_tool -change @executable_path/../Frameworks/libpurple.framework/Versions/0.5.0/libpurple @executable_path/../Frameworks/libpurple.framework/Versions/Current/libpurple
