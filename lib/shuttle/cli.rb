require 'shuttle'
require 'shuttle/deploy'

module Shuttle
  class CLI
    attr_reader :command, :options

    def initialize(command, options={})
      @command = command
      @options = options
    end

    def run!
      config_path = File.expand_path(options[:path])
      if !File.exists?(config_path)
        raise RuntimeError, "Config file #{config_path} does not exist"
      end

      if options[:target].to_s.empty?
        raise RuntimeError, "Deployment target required"
      end

      config = DeployConfig.load_file(config_path)
      config.parse!

      if config.targets[options[:target]].nil?
        raise RuntimeError, "Deployment target #{options[:target]} is not defined"
      end

      target = config.targets[options[:target]]
      Shuttle::Deploy.new(config, target).execute(command)
    end
  end
end