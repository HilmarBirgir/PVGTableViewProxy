Pod::Spec.new do |s|
  s.name             = "PVGTableViewProxy"
  s.version          = "1.1.0"
  s.summary          = "A React inspired component to be able to declaratively use UITableView."
  s.homepage         = "https://github.com/plain-vanilla-games/PVGTableViewProxy"
  s.license          = 'MIT'
  s.author           = {"Jóhann Þ. Bergþórsson" => "johann@plainvanillagames.com", "Hilmar Birgir Ólafsson" => "hilmar@plainvanillagames.com", "Alexander Annas Helgason" => "alliannas@plainvanillagames.com"}
  s.source           = { :git => "https://github.com/plain-vanilla-games/PVGTableViewProxy.git", :tag => s.version.to_s }
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.source_files = 'PVGTableViewProxy'
  s.dependency 'ReactiveCocoa'
end
