module Shuttle
  class Runner
    attr_reader :config_path
    attr_reader :config, :target

    def initialize(config_path, target)
      if !File.exists?(config_path)
        raise ConfigError, "Config file #{config_path} does not exist"
      end

      @config_path = config_path
      @target = target
    end

    def execute(command)
      @config = DeployConfig.load_file(config_path)

      begin
        @config.parse!
      rescue Exception => ex
        raise ConfigError, ex.message
      end

      server = @config.targets[target]

      if server.nil?
        raise ConfigError, "Target #{target} does not exist"
      end

      ssh = Net::SSH::Session.new(server.host, server.user, server.password)
      ssh.open

      klass = Shuttle.const_get(config.app_type.capitalize)
      integration = klass.new(config, ssh, server)
      
      if integration.respond_to?(command)
        begin
          if integration.deploy_running?
            raise DeployError, "Another deployment is running right now..."
          end
          
          integration.write_lock
          integration.send(command.to_sym)
          integration.write_revision
          
        rescue DeployError => err
          exit 1
        rescue Exception => err
          integration.log("ERROR: #{err.message}", 'error')
          exit 1
        ensure 
          integration.release_lock
        end
      else
        raise ConfigError, "Invalid command: #{command}"
      end

      ssh.close
    end
  end
end