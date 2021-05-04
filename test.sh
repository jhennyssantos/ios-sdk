FRAMEWORK=EMVConnectiOS
VERSION=$(grep -m 1 'MARKETING_VERSION' EMVConnectiOS.xcodeproj/project.pbxproj | cut -c 25- | sed 's/;$//' | sed 's/^"//' | sed 's/"$//')
getFinalVersionName() {
  echo ${FRAMEWORK}_${VERSION}.xcframework
}
"$@"

