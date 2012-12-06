require File.expand_path('../lib/shuttle/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "shuttle"
  s.version     = Shuttle::VERSION
  s.summary     = "Deployment automation tool"
  s.description = "To be added"
  s.homepage    = "https://github.com/sosedoff/shuttle"
  s.authors     = ["Dan Sosedoff"]
  s.email       = ["dan.sosedoff@gmail.com"]
  
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec',     '~> 2.11'
  s.add_development_dependency 'simplecov', '~> 0.4'

  s.add_dependency 'net-ssh',          '~> 2.6'
  s.add_dependency 'net-ssh-session',  '~> 0.1.0'
  s.add_dependency 'deploy-config',    '~> 0.1.0'
  s.add_dependency 'terminal_helpers', '~> 0.1'
  s.add_dependency 'chronic_duration', '~> 0.9'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  s.require_paths = ["lib"]
end