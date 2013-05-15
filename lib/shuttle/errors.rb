module Shuttle
  class Error       < StandardError ; end
  class ConfigError < Error         ; end
  class DeployError < Error         ; end
end