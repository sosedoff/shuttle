module Shuttle
  module WordpressCore
    # Get wordpress shared core path
    # @return [String]
    def core_path
      @core_path ||= shared_path('wordpress/core')
    end

    # Check if wordpress core is installed
    # @return [Boolean]
    def core_installed?
      ssh.directory_exists?(core_path) &&
      !ssh.capture("ls #{core_path}").empty?
    end

    # Install wordpress shared core
    # @param [Boolean] overwrite existing code
    # @return [Boolean]
    def core_install(overwrite=true)
      if core_installed? && overwrite == true
        core_remove
      end

      log "Installing WordPress core"

      unless ssh.directory_exists?(core_path)
        ssh.run("mkdir -p #{core_path}")
      end

      cmd = "cd #{core_path} && wp core download"

      if config.wordpress.core
        cmd << " --version=#{config.wordpress.core}"
      end

      result = ssh.run(cmd)

      if result.success?
        log "WordPress core installed"
      else
        error "Unable to install WordPress core: #{result.output}"
      end
    end

    # Remove wordpress shared core
    # @return [Boolean]
    def core_remove
      if ssh.directory_exists?(core_path)
        log "Removing WordPress shared core"
        ssh.run("rm -rf #{core_path}")
      end

      ssh.directory_exists?(core_path)
    end
  end
end