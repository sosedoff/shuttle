module Shuttle
  module Support
    module Bundler
      def bundle_path
        shared_path('bundle')
      end

      def bundler_installed?
        ssh.run("which bundle").success?
      end

      def bundler_version
        ssh.capture("bundle --version").split(' ').last
      end

      def install_bundler
        res = ssh.run("gem install bundler")

        if res.success?
          log "Bundler v#{bundler_version} installed"
        else
          error "Unable to install bundler: #{res.output}"
        end
      end

      def bundle_install
        log "Installing dependencies with bundler"

        cmd = "bundle install --quiet --path #{bundle_path} --binstubs --deployment"

        res = ssh.run("cd #{release_path} && #{cmd}", &method(:stream_output))

        unless res.success?
          error "Unable to run bundle: #{res.output}"
        end
      end
    end
  end
end