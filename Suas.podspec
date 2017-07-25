Pod::Spec.new do |s|
  s.name = 'Suas'
  s.version = '0.1.1'
  s.license = 'MIT'
  s.summary = 'Library that does something'
  s.homepage = 'https://github.com/Zendesk/Suas-iOS'
  s.authors = { 'Omar Abdelhafith' => 'o.arrabi@me.com' }
  s.source = { :git => 'https://github.com/Zendesk/Suas-iOS.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'  

  s.source_files = 'Sources/**/**.swift'
end