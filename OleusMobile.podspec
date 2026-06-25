Pod::Spec.new do |s|
  s.name         = "OleusMobile"
  s.version      = "0.8.3"
  s.summary      = "Oleus crash reporting, session tracking, and observability SDK for iOS."
  s.description  = <<-DESC
    OleusMobile captures crashes (C-level signal handler + NSException),
    ANR-equivalent hangs via MetricKit, breadcrumbs, screen tracking,
    network instrumentation, and session replay — all shipped through a
    disk-backed OTLP queue that survives process death.
  DESC

  s.homepage     = "https://github.com/oleus-io/oleus-mobile-ios"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Oleus" => "info@oleus.io" }
  s.source       = { :git => "https://github.com/oleus-io/oleus-mobile-ios.git", :tag => s.version.to_s }

  s.ios.deployment_target = "15.0"
  s.swift_versions = ["5.7", "5.8", "5.9", "5.10", "6.0"]

  s.default_subspecs = "Core"

  s.subspec "Core" do |core|
    core.source_files = "Sources/OleusMobile/**/*.swift"
    core.dependency "OleusMobile/CrashCore"
    core.frameworks = "Foundation", "MetricKit"
    core.weak_frameworks = "UIKit"
  end

  s.subspec "CrashCore" do |cc|
    cc.source_files = "Sources/OleusCrashCore/**/*.{c,h}"
    cc.public_header_files = "Sources/OleusCrashCore/include/**/*.h"
    cc.module_map = "Sources/OleusCrashCore/include/module.modulemap"
    cc.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  end
end
