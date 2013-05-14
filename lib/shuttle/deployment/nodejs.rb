module Shuttle
  class Nodejs < Shuttle::Deploy
    def setup
      if node_installed?
        log "Using Node.js v#{node_version}, NPM v#{npm_version}"
      else
        error "Node.js is not installed."
      end

      super
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
  end
end