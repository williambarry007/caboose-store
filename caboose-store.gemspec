$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "caboose-store/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "caboose-store"
  s.version     = CabooseStore::VERSION
  s.authors     = ["William Barry"]
  s.email       = ["william@nine.is"]
  s.homepage    = "http://github.com/williambarry007/caboose-store"
  s.summary     = "E-Commerce plugin for Caboose CMS"
  s.description = "Sell products on your site using Caboose."
  s.files       = Dir["{app,config,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files  = Dir["test/**/*"]
  s.executables = ['']
  
  s.add_dependency "caboose-cms"
end
