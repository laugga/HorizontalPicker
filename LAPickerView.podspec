Pod::Spec.new do |s|
  s.name         = 'LAPickerView'
  s.version      = '0.2.0'
  s.summary      = 'Horizontal spinning-wheel picker view for iOS.'
# s.description  = <<-DESC
#                   * Markdown format.
#                   * Don't worry about the indent, we strip it!
#                  DESC
  s.homepage     = 'https://github.com/laugga/lapickerview'
# s.screenshots  = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license      = 'MIT'
  s.author       = { 'Luis Laugga' => 'luis@laugga.com' }
  s.source       = { :git => 'https://github.com/laugga/LAPickerView.git', :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = false

  s.source_files = 'lib/*'
  s.resources = "resources/*.{png,jpeg,jpg,storyboard,xib,xcassets,caf}"

  s.public_header_files = 'lib/*.h'
  s.prefix_header_file = 'support/LAPickerView-Prefix.pch'
  s.frameworks = 'Foundation', 'UIKit', 'CoreGraphics', 'QuartzCore', 'CoreText', 'AudioToolbox'
end
