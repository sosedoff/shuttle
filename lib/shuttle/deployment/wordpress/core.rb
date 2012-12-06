module Shuttle
  module WordpressCore
    def core_installed?
      ssh.directory_exists?(shared_path('wp-core')) &&
      !ssh.capture("ls #{shared_path('wp-core')}").empty?
    end

    def core_install
      if core_installed?
        log "Removing existing wp-core"
        ssh.run("cd #{shared_path} && rm -rf wp-core")
      end

      log "Installing wordpress core"

      if ssh.run("cd #{shared_path('wp-core')} && wp core download").success?
        log "Wordpress core installed"
      else
        log "Unable to install wordpress core"
      end
    end
  end
end