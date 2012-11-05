module Shuttle
  module Deployment
    include TerminalHelpers

    class Base
      attr_reader :config
      attr_reader :target
      attr_reader :ssh
      attr_reader :version

      def initialize(config, target, session)
        @config  = config
        @ssh     = session
        @target  = target
        @version = "1"

        if ssh.file_exists?(version_path)
          @version = (Integer(ssh.capture("cat #{version_path}")) + 1).to_s
        end
      end

      def log(message, level='info')
        puts "----->".green + " #{message}"
      end

      def execute(command)
        self.send(command.to_sym)
      end

      # Get deployment root path
      # @param path [String] relative path
      # @return [String]
      def deploy_path(path=nil)
        base = target.deploy_to
        path ? File.join(base, path) : base
      end

      # Get current release path
      # @return [String]
      def current_path
        deploy_path('current')
      end

      # Get current build path
      # @return [String]
      def build_path
        deploy_path('build')
      end

      def version_path
        deploy_path('version')
      end

      # Get release path
      # @param path [String] relative to release path
      # @return [String]
      def release_path(path=nil)
        base = File.join(deploy_path('releases'), version)
        path ? File.join(base, path) : base
      end

      # Create an initial directory structure for application
      def setup
        log("Running setup")

        ssh.run("mkdir -p #{deploy_path}")
        ssh.run("mkdir -p #{deploy_path}/releases")
        ssh.run("mkdir -p #{deploy_path}/shared")
        ssh.run("mkdir -p #{deploy_path}/tmp")
        ssh.run("touch #{deploy_path}/version")
      end

      def update_code
        # If there is no codebase installed, get the code first
        if ssh.file_exists?(deploy_path('scm'))
          log("Updating to the latest code")
          ssh.run("cd #{deploy_path('scm')} && git pull")
        else
          log("Getting latest code")
          ssh.run("cd #{deploy_path} && git clone --recursive --quiet #{config.git} scm")
        end
      end

      # Checkout the latest code
      #
      # If the deployment configuration does not have a git head to checkout
      # it will use master branch by default
      #
      def checkout_code
        ssh.run("cd #{deploy_path('scm')} && git checkout-index -f -a --prefix=#{release_path}/")
      end

      # Link new release to the current
      def link_release
        log "Linking release..."
        if ssh.file_exists?(current_path)
          ssh.run("unlink #{current_path}")
        end

        ssh.run("ln -s #{release_path} #{current_path}")
        ssh.run("echo #{version} > #{version_path}")

        log "Release v#{version} has been deployed"
      end

      def create_build_dir
        ssh.run("mkdir #{build_path}")
      end

      def destroy_build_dir
        if ssh.file_exists?(build_path)
          ssh.run("rm -rf #{build_path}")
        end
      end
    end
  end
end