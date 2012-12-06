module Shuttle
  module WordpressCli
    CLI_GIT = 'https://github.com/wp-cli/wp-cli.git'

    def cli_installed?
      ssh.run("which wp").success?
    end

    def cli_install
      log "Installing wordpress CLI"
      
      path = '/tmp/install'

      ssh.run_multiple([
        "mkdir -p #{path}",
        "cd #{path} && git clone --recursive --quiet #{CLI_GIT}",
        "cd #{path}/wp-cli && sudo utils/dev-build"
      ])

      if cli_installed?
        log "Wordpress CLI installed"
        ssh.run("rm -rf /tmp/install")
      else
        error "Unable to install wordpress CLI"
      end
    end

    def plugin_install(name)
      log "Installing wordpress plugin: #{name}"
      res = ssh.run("cd #{release_path} && wp plugin install #{name}")
      if !res.success?
        error "Unable to install plugin '#{name}'. Reason: #{res.output}"
      end
    end
  end
end