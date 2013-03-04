module Shuttle
  module Support::Thin
    def thin_port
      "9000"
    end

    def thin_env
      environment
    end

    def thin_options
      [
        "-a 127.0.0.1",
        "-p #{thin_port}",
        "-e #{thin_env}",
        "-l #{shared_path('log/thin.log')}",
        "-P #{shared_path('pids/thin.pid')}",
        "-d"
      ].join(' ')
    end

    def thin_start
      log "Starting thin"

      res = ssh.run("cd #{release_path} && ./bin/thin #{thin_options} start")

      if res.success?
        log "Thin started"
      else
        error "Unable to start thin: #{res.output}"
      end
    end

    def thin_stop
      log "Stopping thin"

      ssh.run("cd #{release_path} && ./bin/thin #{thin_options} stop")
    end

    def thin_restart
      log "Restarting thin"

      if ssh.file_exists?(shared_path('pids/thin.pid'))
        thin_stop
      end

      thin_start
    end
  end
end