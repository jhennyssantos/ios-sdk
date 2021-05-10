Pod::Spec.new do |s| 
    s.name              = 'EMVConnectiOS'
    s.version           = "VERSION"
    s.summary           = 'Zoop EMVConnect for IOS Devices'
    s.homepage          = 'https://docs.zoop.co/docs/sdk-ios'

    s.author            = { 'Zoop Mobile CP' => 'mobile-cp@zoop.com.br' }
    s.license           = { :type => 'MIT', :file => 'license' }

    s.platform          = :ios
    s.source            = { :http => 'https://zoop-release-sdk-ios-prd.s3.sa-east-1.amazonaws.com/EMVConnect/iOS/VERSION/EMVConnectiOS.zip' }
    s.source_files      = "EMVConnectiOS.framework/**/*.{h,m}"
end
