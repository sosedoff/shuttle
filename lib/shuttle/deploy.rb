module Shuttle
  class Deploy
    include Shuttle::Helpers
    include Shuttle::PathHelpers

    attr_reader :ssh
    attr_reader :target
    attr_reader :environment
    attr_reader :version
    attr_reader :config

    def initialize(config, ssh, target, environment)
      @config      = config
      @target      = target
      @ssh         = ssh
      @environment = environment

      if ssh.file_exists?(version_path)
        res = ssh.capture("cat #{version_path}")
        @version = (res.empty? ? 1 : Integer(res) + 1).to_s
      else
        @version = 1
      end
    end
  end
end