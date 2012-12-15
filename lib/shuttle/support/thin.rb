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
        "-a 0.0.0.0",
        "-p #{thin_port}",
        "-e #{thin_env}",
        "-l #{shared_path('log/thin.log')}",
        "-P #{shared_path('pids/thin.pid')}",
        "-d"
      ].join(' ')
    end

    def thin_start
      log "Starting thin"

      if ssh.run("cd #{release_path} && ./bin/thin #{thin_options} start").success?
        log "Thin started"
      else
        error "Unable to start thin"
      end
    end

    def thin_stop
      log "Starting thin"

      if ssh.run("cd #{release_path} && ./bin/thin #{thin_options} start").success?
        log "Thin stop"
      else
        error "Unable to stop thin"
      end
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