require 'deploy-config'
require 'terminal_helpers'
require 'net/ssh/session'

require 'shuttle/version'
require 'shuttle/errors'

module Shuttle
  autoload :Runner,    'shuttle/runner'
  autoload :Deploy,    'shuttle/deploy'
  autoload :Tasks,     'shuttle/tasks'

  autoload :Wordpress, 'shuttle/deployment/wordpress'
  autoload :Static,    'shuttle/deployment/static'
end