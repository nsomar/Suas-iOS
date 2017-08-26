Pod::Spec.new do |s|
  s.name = 'Suas'
  s.version = '1.0.0'
  s.license = 'MIT'
  s.summary = 'Suas is a Unidirectional data flow architecture implementation for iOS, macOS, tvOS and watchOS'
  s.homepage = 'http://suas.readme.io'
  s.authors = { 'Omar Abdelhafith' => 'o.arrabi@me.com' }
  s.source = { :git => 'https://github.com/Zendesk/Suas-iOS.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'  

  s.source_files = 'Sources/**/**.swift'
end