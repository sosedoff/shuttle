module Shuttle
  class Nodejs < Shuttle::Deploy
    def setup
      if node_installed?
        log "Using Node.js v#{node_version}, Npm v#{npm_version}"
      else
        error "Node.js is not installed."
      end

      super
    end

    def deploy
      setup
      update_code
      checkout_code
      install_dependencies
      link_release
      cleanup_releases
    end

    private

    def node_installed?
      ssh.run("which node").success?
    end

    def node_version
      ssh.run("node -v").output.strip.gsub('v', '')
    end

    def npm_version
      ssh.run("npm -v").output.strip
    end

    def install_dependencies
      if ssh.file_exists?("#{release_path}/package.json")
        log "Installing application dependencies"

        result = ssh.run("cd #{release_path} && npm install")

        if result.failure?
          error "Unable to install dependencies: #{result.output}"
        end
      end
    end
  end
end