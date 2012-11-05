require File.expand_path('../lib/shuttle/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "shuttle"
  s.version     = Shuttle::VERSION
  s.summary     = "Deployment automation tool"
  s.description = "To be added"
  s.homepage    = "Project homepage"
  s.authors     = ["Dan Sosedoff"]
  s.email       = ["dan.sosedoff@gmail.com"]
  
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec',     '~> 2.11'
  s.add_development_dependency 'simplecov', '~> 0.4'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  s.require_paths = ["lib"]
end