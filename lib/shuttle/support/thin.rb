module Shuttle
  module Support::Thin
    def thin_config
      config.thin || Hashr.new
    end

    def thin_host
      thin_config.host || "127.0.0.1"
    end

    def thin_port
      thin_config.port || "9000"
    end

    def thin_servers
      thin_config.servers || 1
    end

    def thin_env
      environment
    end

    def thin_options
      [
        "-a #{thin_host}",
        "-p #{thin_port}",
        "-e #{thin_env}",
        "-s #{thin_servers}",
        "-l #{shared_path('log/thin.log')}",
        "-P #{shared_path('pids/thin.pid')}",
        "-d"
      ].join(' ')
    end

    def thin_start
      log "Starting thin"

      res = ssh.run("cd #{release_path} && ./bin/thin #{thin_options} start")

      unless res.success?
        error "Unable to start thin: #{res.output}"
      end
    end

    def thin_stop
      log "Stopping thin"

      ssh.run("cd #{release_path} && ./bin/thin #{thin_options} stop")
    end

    def thin_restart
      if ssh.file_exists?(shared_path('pids/thin.pid'))
        thin_stop
      end

      thin_start
    end
  end
end