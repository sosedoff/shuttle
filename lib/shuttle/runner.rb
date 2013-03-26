require 'logger'
require 'safe_yaml'

module Shuttle
  class Runner
    attr_reader :options
    attr_reader :config_path
    attr_reader :config, :target

    def initialize(options)
      @options     = options
      @config_path = File.expand_path(options[:path])
      @target      = options[:target]

      if !File.exists?(config_path)
        raise ConfigError, "Config file #{config_path} does not exist"
      end

      @config_path = config_path
      @target = target
    end

    def load_config
      data = File.read(config_path)
      Hashr.new(YAML.safe_load(data))
    end

    def validate_target(target)
      if target.host.nil?
        raise ConfigError, "Target host required"
      end

      if target.user.nil?
        raise ConfigError, "Target user required"
      end

      if target.deploy_to.nil?
        raise ConfigError, "Target deploy path required"
      end
    end

    def execute(command)
      @config = load_config

      strategy = config.app.strategy
      if strategy.nil?
        raise ConfigError, "Invalid strategy: #{strategy}"
      end

      if @config.target
        server = @config.target
      else
        if @config.targets.nil?
          raise ConfigError, "Please define deployment target"
        end

        server = @config.targets[target]
        if server.nil?
          raise ConfigError, "Target #{target} does not exist"
        end
      end

      validate_target(server)

      ssh = Net::SSH::Session.new(server.host, server.user, server.password)

      if options[:log]
        ssh.logger = Logger.new(STDOUT)
      end

      ssh.open

      klass = Shuttle.const_get(strategy.capitalize)
      integration = klass.new(config, ssh, server, target) 

      command.gsub!(/:/,'_')
      exit_code = 0
      puts "\n"

      integration.log "Shuttle v#{Shuttle::VERSION}"
      integration.log "Connected to #{server.user}@#{server.host}"
      
      if integration.respond_to?(command)
        time_start = Time.now

        begin
          if integration.deploy_running?
            deployer = ssh.read_file("#{integration.deploy_path}/.lock").strip
            message = "Another deployment is running."
            message << " Deployer: #{deployer}" if deployer.size > 0

            integration.error(message)
          end

          integration.write_lock
          integration.export_environment
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
          puts "\nExecution time: #{duration}\n"
        end

        puts "\n"
        exit(exit_code)

      else
        raise ConfigError, "Invalid command: #{command}"
      end

      ssh.close
    rescue Net::SSH::AuthenticationFailed
      STDERR.puts "Authentication failed"
      exit 1
    end
  end
end