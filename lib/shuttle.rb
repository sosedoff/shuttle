require 'terminal_helpers'
require 'net/ssh/session'
require 'chronic_duration'
require 'toml'
require 'hashr'
require 'yaml'
require 'digest/sha1'

require 'shuttle/version'
require 'shuttle/errors'

module Shuttle
  autoload :Session,   'shuttle/session'
  autoload :Runner,    'shuttle/runner'
  autoload :Deploy,    'shuttle/deploy'
  autoload :Tasks,     'shuttle/tasks'
  autoload :Target,    'shuttle/target'
  autoload :Helpers,   'shuttle/helpers'

  autoload :Static,    'shuttle/deployment/static'
  autoload :Php,       'shuttle/deployment/php'
  autoload :Wordpress, 'shuttle/deployment/wordpress'
  autoload :Rack,      'shuttle/deployment/rack'
  autoload :Rails,     'shuttle/deployment/rails'

  module Support
    autoload :Bundler, 'shuttle/support/bundler'
    autoload :Foreman, 'shuttle/support/foreman'
    autoload :Thin,    'shuttle/support/thin'
  end
end