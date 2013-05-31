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
      tags = ssh.capture("cd #{CLI_PATH} && git tag").split("\n").map(&:strip).reverse
      tag  = tags.first
      rev  = ssh.capture("cd #{CLI_PATH} && git rev-parse #{tag}").strip

      ssh.run("cd #{CLI_PATH} && git checkout #{rev}")
      ssh.run("cd #{CLI_PATH} && sudo utils/dev-build")
      
      if cli_installed?
        log "Wordpress CLI (#{tag}) installed"
      else
        error "Unable to install wordpress CLI"
      end
    end
  end
end