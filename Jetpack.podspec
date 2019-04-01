Pod::Spec.new do |s|
  s.name         = "Jetpack"
  s.version      = "4.1.1"
  s.summary      = "Light and bright functional reactive framework"
  s.description  = <<-DESC
    Minimalistic implementation of rx primitives
  DESC
  s.homepage     = "https://github.com/psharanda/Jetpack"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Pavel Sharanda" => "edvaef@gmail.com" }
  s.social_media_url   = "https://twitter.com/e2f"
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/psharanda/Jetpack.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation"
end
