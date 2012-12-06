module Shuttle
  module Support::Foreman
    def foreman_installed?
      ssh.run("which foreman").success?
    end
  end
end