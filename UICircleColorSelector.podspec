

Pod::Spec.new do |s|

  s.name         = "UICircleColorSelector"
  s.version      = "1.0.7"
  s.summary      = "Simple circle color selector."
  s.swift_version = "4.1"
  s.description  = "Simple circle color selector for IOS writen in SWIFT"
  s.homepage     = "https://github.com/dimzhurwork/UICircleColorSelector"
  s.screenshots  = "https://github.com/dimzhurwork/UICircleColorSelector/raw/master/screen.png?raw=true"
  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.authors      = { 'Dmitriy Zhuravlev' => 'dimzhurwork@yandex.ru' }
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/dimzhurwork/UICircleColorSelector.git", :tag => "#{s.version}" }
  s.source_files  = "UICircleColorSelector/*.swift"
end
