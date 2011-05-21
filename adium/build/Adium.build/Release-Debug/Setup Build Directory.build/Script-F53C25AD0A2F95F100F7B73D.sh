#!/bin/sh
SOURCE="$SRCROOT/build"
if [ "$SOURCE" != "$SYMROOT" ] ; then
	if [ -d "$SOURCE" ] ; then
		/bin/rm -Rf "$SOURCE"
	fi
	/bin/ln -fs "$SYMROOT" "$SOURCE"
fi
