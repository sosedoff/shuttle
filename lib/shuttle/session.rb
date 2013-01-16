module Shuttle
  class Session
    attr_reader :config, :target

    # Initialize a new session
    # @param [Hashr] deploy config
    # @param [String] deploy target
    def initialize(config, target)
      @config = config
      @target = target
    end

    def validate
      if config.app.strategy.nil?
        raise ConfigError, "Deployment strategy is required"
      end

      if config.targets[target].nil?
        raise ConfigError, "Target does not exist"
      end
    end

    def run(command)
      strategy = config.app.strategy
      server = config.targets[target]

      ssh = Net::SSH::Session.new(server.host, server.user, server.password)
      ssh.open

      klass = Shuttle.const_get(strategy.capitalize)
      integration = klass.new(config, ssh, server, target)

      if integration.deploy_running?
        raise DeployError, "Another deployment is running"
      end

      begin
        integration.write_lock
        integration.send(command.to_sym)
        integration.write_revision
      rescue DeployError => err
        integration.cleanup_release
      rescue Exception => err
        integration.cleanup_release
      ensure
        integration.release_lock
      end

      ssh.close
    end
  end
end