module Shuttle
  module WordpressCli
    CLI_GIT  = 'https://github.com/wp-cli/wp-cli.git'
    CLI_PATH = '/usr/local/share/wp-cli'

    # Check if CLI is installed
    # @return [Boolean]
    def cli_installed?
      ssh.run("which wp").success?
    end

    # Install wordpress CLI
    # @return [Boolean]
    def cli_install
      log "Installing wordpress CLI"

      ssh.run("sudo git clone --recursive --quiet #{CLI_GIT} #{CLI_PATH}")
      ssh.run("cd #{CLI_PATH} && sudo utils/dev-build")
      
      if cli_installed?
        log "Wordpress CLI installed"
      else
        error "Unable to install wordpress CLI"
      end
    end

    # Install wordpresss plugin
    # @param [String] plugin name slug
    def plugin_install(name)
      log "Installing plugin: #{name}"

      res = ssh.run("cd #{release_path} && wp plugin install #{name}")
      if !res.success?
        error "Unable to install plugin '#{name}'. Reason: #{res.output}"
      end
    end

    def plugin_custom_install(name, url)
      log "Installing custom plugin: #{name} -> #{url}"

      if url.include?('.git') || url.include?('git@') || url.include?('git://')
        ssh.run "cd #{release_path}/wp-content/plugins"
        res = ssh.run "git clone #{url} #{name}"

        if res.failure?
          error "Unable to install plugin '#{name}'. Reason: #{res.output}"
        end

        ssh.run("rm -rf #{release_path}/wp-content/plugins/#{name}/.git")
      else
        error "Valid git URL is required for plugin: #{name}"
      end
    end

    # Check if wordpress plugin is installed
    # @return [Boolean]
    def plugin_installed?(name)
      raise "Not Implemented"
    end
  end
end