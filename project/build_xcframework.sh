#!/bin/bash
# This generates one ring to rule them all: a single .xcframework for all platforms and devices.
# This script is configured by, but not called by, cmake. The final script is written to the build directory and named
# `build_xcframework.sh`
# You will need to manually edit the resulting script file if you want to code sign the framework, although
# usually you don't need to because consumers will "Embed and Sign" within Xcode

# Set to codesign each framework of the xcframework.
# Use your 10-character team identifier (you can find this in appstoreconnect).
MY_TEAM_ID=""

# Configure the build type for all frameworks in the xcframework
ARCHIVE_CONFIGURATION=MinSizeRel

# Specify the minimum version of Xcode to compile with. Must be installed on this system!
XCODE_VER=13.2

# ===================================================
# Shouldn't need to manually edit anything below this
# ===================================================

# Ensure we have the correct version of Xcode
XCODE_VER_INS=$(xcodebuild -version | head -1 | cut -d' ' -f2)
if [ "$XCODE_VER_INS" != "$XCODE_VER" ]; then
  echo "Building this xcframework requires building with a version of XCode that matches the minimum target $XCODE_VER, but your xcode build tools are set to $XCODE_VER_INS. Please change your terminal build tools to the matching version of Xcode in order to run this script."
  echo "Example:"
  echo "  sudo xcode-select -s /Applications/Xcode_$XCODE_VER.app/Contents/Developer"
  exit 0
fi

ARCHIVE_IOS_PATH=ios
ARCHIVE_SIM_PATH=simulator
FINAL_PRODUCT=zfp.xcframework

# Start fresh
xcodebuild -project zfp.xcodeproj -scheme zfp_iOS clean
rm -rf $ARCHIVE_IOS_PATH $ARCHIVE_SIM_PATH $FINAL_PRODUCT

# iOS device variant
xcodebuild archive -project zfp.xcodeproj -scheme zfp_iOS -configuration $ARCHIVE_CONFIGURATION -destination generic/platform=iOS -archivePath $ARCHIVE_IOS_PATH/zfp.xcarchive BUILD_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO

# iOS simulator variant
xcodebuild archive -project zfp.xcodeproj -scheme zfp_simulator -configuration $ARCHIVE_CONFIGURATION -destination "generic/platform=iOS Simulator" -archivePath $ARCHIVE_SIM_PATH/zfp.xcarchive BUILD_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO

# Codesign the individual frameworks (optional)
if [ ! -z "$MY_TEAM_ID" ]; then
   codesign --verbose -s $MY_TEAM_ID $ARCHIVE_IOS_PATH/zfp.xcarchive
   codesign --verbose -s $MY_TEAM_ID $ARCHIVE_SIM_PATH/zfp.xcarchive
else
   echo "Not code signing, no team has been specified. If this is a mistake then please edit this script and try again"
fi

# Package all variants into a single .xcframework
xcodebuild -create-xcframework -framework $ARCHIVE_IOS_PATH/zfp.xcarchive/Products/Library/Frameworks/zfp.framework -framework $ARCHIVE_SIM_PATH/zfp.xcarchive/Products/Library/Frameworks/zfp.framework -output $FINAL_PRODUCT

# Codesign the final xcframework (optional)
if [ ! -z "$MY_TEAM_ID" ]; then
   codesign --verbose -s $MY_TEAM_ID zfp.xcframework
fi
