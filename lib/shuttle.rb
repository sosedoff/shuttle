require 'terminal_helpers'
require 'net/ssh/session'
require 'chronic_duration'
require 'toml'
require 'hashr'
require 'yaml'
require 'safe_yaml'
require 'toml'
require 'digest/sha1'
require 'logger'

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
  autoload :Ruby,      'shuttle/deployment/ruby'
  autoload :Rails,     'shuttle/deployment/rails'
  autoload :Nodejs,    'shuttle/deployment/nodejs'

  module Support
    autoload :Bundler, 'shuttle/support/bundler'
    autoload :Foreman, 'shuttle/support/foreman'
    autoload :Thin,    'shuttle/support/thin'
  end
end