module Shuttle
  module WordpressCli
    CLI_GIT  = 'https://github.com/wp-cli/wp-cli.git'
    CLI_PATH = '/usr/local/share/wp-cli'

    def cli_installed?
      ssh.run("which wp").success?
    end

    def cli_install
      log "Installing WordPress CLI"

      ssh.run("sudo git clone --recursive --quiet #{CLI_GIT} #{CLI_PATH}")

      if config.wordpress.cli.nil?
        tags = ssh.capture("cd #{CLI_PATH} && git tag").split("\n").map(&:strip).reverse
        tag  = tags.first
        rev  = ssh.capture("cd #{CLI_PATH} && git rev-parse #{tag}").strip
      else
        tag = rev = config.wordpress.cli
      end

      ssh.run("cd #{CLI_PATH} && git checkout #{rev}")
      ssh.run("cd #{CLI_PATH} && sudo utils/dev-build")
      
      if cli_installed?
        log "Wordpress CLI (#{tag}) installed"
      else
        error "Unable to install WordPress CLI"
      end
    end

    def cli_uninstall
      ssh.run("sudo rm $(which wp)")
      ssh.run("sudo rm -rf #{CLI_PATH}")
    end
  end
end