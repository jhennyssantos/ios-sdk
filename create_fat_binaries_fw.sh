source test.sh

FRAMEWORK=EMVConnectiOS
SCHEME=EMVConnectiOS
BUILD=build
FRAMEWORK_PATH=$FRAMEWORK.framework
FRAMEWORK_RESULT_NAME=$FRAMEWORK.xcframework


# iOS
rm -Rf $FRAMEWORK/$BUILD
rm -f $FRAMEWORK.framework.tar.gz
rm -f $FRAMEWORK.xcframework.tar.gz

SIMULATOR_ARCHIVE="$BUILD/$FRAMEWORK.framework-iphoneos.xcarchive"
DEVICE_ARCHIVE="$BUILD/$FRAMEWORK.framework-iphonesimulator.xcarchive"
CATALYST_ARCHIVE="$BUILD/$FRAMEWORK.framework-catalyst.xcarchive"
MAIN_DIR="$(pwd)"
#VERSION=$(grep -m 1 'MARKETING_VERSION' EMVConnectiOS.xcodeproj/project.pbxproj | cut -c 25- | sed 's/;$//' | sed 's/^"//' | sed 's/"$//')
RESULT_FRAMEWORK="${MAIN_DIR}/${FRAMEWORK}_${VERSION}.xcframework"
FRAMEWORK_RESULT_NAME=$( getFinalVersionName )



# Device slice.
xcodebuild archive -project "$FRAMEWORK.xcodeproj" -scheme "$SCHEME" -configuration Release -destination 'generic/platform=iOS' -archivePath "$SIMULATOR_ARCHIVE" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

# Simulator slice.
xcodebuild archive -project "$FRAMEWORK.xcodeproj" -scheme "$SCHEME" -configuration Release -destination 'generic/platform=iOS Simulator' -archivePath "$DEVICE_ARCHIVE" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

# Mac Catalyst slice.
xcodebuild archive -project "$FRAMEWORK.xcodeproj" -scheme "$SCHEME" -configuration Release -destination 'platform=macOS,arch=x86_64,variant=Mac Catalyst' -archivePath "$CATALYST_ARCHIVE" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES


xcodebuild build -project $FRAMEWORK.xcodeproj -target $SCHEME -sdk iphonesimulator SYMROOT=$BUILD
xcodebuild -create-xcframework -framework "$SIMULATOR_ARCHIVE/Products/Library/Frameworks/$FRAMEWORK.framework" -framework "$DEVICE_ARCHIVE/Products/Library/Frameworks/$FRAMEWORK.framework" -framework "$CATALYST_ARCHIVE/Products/Library/Frameworks/$FRAMEWORK.framework" -output "$RESULT_FRAMEWORK"


tar -czv -f $FRAMEWORK_RESULT_NAME.tar.gz $FRAMEWORK_RESULT_NAME