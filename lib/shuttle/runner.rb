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
      data = File.read(config_path).strip

      if data.empty?
        raise ConfigError, "Configuration file is empty"
      end

      if config_path =~ /\.toml$/
        parse_toml_data(data)
      else
        parse_yaml_data(data)
      end
    end

    def parse_yaml_data(data)
      Hashr.new(YAML.safe_load(data))
    end

    def parse_toml_data(data)
      Hashr.new(TOML::Parser.new(data).parsed)
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

      strategy = config.app.strategy || 'static'
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

      klass = Shuttle.const_get(strategy.capitalize) rescue nil
      command.gsub!(/:/,'_')
      exit_code = 0

      if klass.nil?
        STDERR.puts "Invalid strategy: #{strategy}"
        exit 1
      end

      unless %w(setup deploy rollback).include?(command)
        STDERR.puts "Invalid command: #{command}"
        exit 1
      end

      integration = klass.new(config, ssh, server, target)

      puts "\n"
      puts "Shuttle v#{Shuttle::VERSION}\n"
      puts "\n"
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
        rescue Interrupt
          STDERR.puts "Interrupted by user. Aborting deploy..."
          exit_code = 1
        rescue Exception => err
          integration.cleanup_release
          integration.log("Shuttle ERROR: #{err.message}", 'error')
          integration.log(err.backtrace.join("\n"), 'error')

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
    rescue SocketError => err
      STDERR.puts "Socket error: #{err.message}"
      exit 1
    rescue Net::SSH::AuthenticationFailed
      STDERR.puts "SSH Authentication failed"
      exit 1
    end
  end
end