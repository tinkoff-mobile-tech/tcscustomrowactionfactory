Pod::Spec.new do |s|
  s.name             = 'TCSCustomRowActionFactory'
  s.version          = '1.0.0'
  s.summary          = 'TCSCustomRowActionFactory - universal solution for swipe actions'
  s.description      = 'TCSCustomRowActionFactory allows you to setup the swipe actions for cells in a table view in any way using UIView and other convenient methods'

  s.homepage         = 'https://github.com/TinkoffCreditSystems/tcscustomrowactionfactory'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Alexander Trushin' => 'a.trushin@tinkoff.ru' }
  s.source           = { :git => 'https://github.com/TinkoffCreditSystems/tcscustomrowactionfactory.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.swift_version = '4.2'

  s.source_files = 'TCSCustomRowActionFactory/Classes/**/*.swift'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Foundation'
end
