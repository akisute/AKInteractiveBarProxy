Pod::Spec.new do |s|
  s.name                  = "AKInteractiveBarProxy"
  s.version               = "1.0.0"
  s.summary               = "A proxy object which helps you to make Safari-like interactive animation bars on UIScrollView."
  s.description           = <<-DESC
                  AKInteraeBarProxy library provides a proxy object which helps you to make Safari-like interactive animation bars on UIScrollView. The proxy works as a delegate object for UIScrollView and its subclasses to interact with user inputs. Once user scrolls around on the scroll view, AKInteractiveBarProxy analyse scroll gestures and parse it to its delegate as an interactive animation.
                            DESC
  s.homepage              = "https://github.com/akisute/AKInteractiveBarProxy"
  s.license               = "MIT"
  s.author                = { "Masashi Ono" => "akisutesama@gmail.com" }
  s.source                = { :git => "https://github.com/akisute/AKInteractiveBarProxy.git", :tag => s.version.to_s }
  s.platform              = :ios, "7.0"
  s.requires_arc          = true
  s.source_files          = "Sources-ObjC/AKInteractiveBarProxy.*"
  #s.resources             = ""
  #s.public_header_files   = ""
  s.frameworks            = "UIKit"
end
