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
      @config = Hashr.new(YAML.load_file(config_path))
      server = @config.targets[target]

      if server.nil?
        raise ConfigError, "Target #{target} does not exist"
      end

      ssh = Net::SSH::Session.new(server.host, server.user, server.password)
      ssh.open

      klass = Shuttle.const_get(config.app.strategy.capitalize)
      integration = klass.new(config, ssh, server)

      command.gsub!(/:/,'_')
      exit_code = 0
      puts "\n"
      
      if integration.respond_to?(command)
        time_start = Time.now

        begin
          if integration.deploy_running?
            integration.error "Another deployment is running right now..."
          end
          
          integration.write_lock
          integration.send(command.to_sym)
          integration.write_revision

        rescue DeployError => err
          integration.cleanup_release
          exit_code = 1
        rescue SystemExit
          # NOOP
          exit_code = 0
        rescue Exception => err
          integration.cleanup_release
          integration.log("ERROR: #{err.message}", 'error')
          exit_code = 1
        ensure
          integration.release_lock
        end

        if exit_code == 0
          diff = (Float(Time.now - time_start) * 100).round / 100
          duration = ChronicDuration.output(diff, :format => :short)
          puts "\nRun time: #{duration}\n"
        end

        puts "\n"
        exit(exit_code)

      else
        raise ConfigError, "Invalid command: #{command}"
      end

      ssh.close
    end
  end
end