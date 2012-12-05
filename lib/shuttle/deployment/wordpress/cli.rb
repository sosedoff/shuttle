module Shuttle
  module WordpressCli
    CLI_GIT = 'https://github.com/wp-cli/wp-cli.git'

    def cli_installed?
      ssh.run("which wp").success?
    end

    def install_cli
      log "Installing CLI"
      path = '/tmp/install'

      ssh.run_multiple([
        "mkdir -p #{path}",
        "cd #{path} && git clone --recursive --quiet #{CLI_GIT}",
        "cd #{path}/wp-cli && sudo utils/dev-build"
      ])

      if cli_installed?
        log "CLI installed."
        ssh.run("rm -rf /tmp/install")
      else
        error "Unable to install CLI."
      end
    end
  end
end