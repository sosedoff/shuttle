module Shuttle
  class NodeJs < Shuttle::Deploy
    def setup
      error "Please install Node.js first" unless node_installed?

      log "Using Node.js v#{node_version}, NPM v#{npm_version}"

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