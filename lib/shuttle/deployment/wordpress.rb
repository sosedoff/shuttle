module Shuttle
  module Deployment
    class Wordpress < Base
      CLI_GIT = 'https://github.com/wp-cli/wp-cli.git'

      def deploy
        setup
        update_code
      end

      # Check if Wordpress CLI tools are installed
      # @return [Boolean]
      def wp_cli_installed?
        ssh.run("which wp").success?
      end

      # Install wordpress CLI tools
      def install_wp_cli
        path = '/tmp/install'

        ssh.run_batch(
          "mkdir -p #{path}",
          "cd #{path} && git clone --recursive --quiet #{CLI_GIT}",
          "cd #{path}/wp-cli && sudo utils/dev-build"
        )
      end

      # Install wordpress core library
      def install_wp_core
        
      end
    end
  end
end