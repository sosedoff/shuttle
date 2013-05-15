module Shuttle
  class Ruby < Shuttle::Strategy
    include Shuttle::Support::Bundler
    include Shuttle::Support::Thin

    def setup
      unless ruby_installed?
        error "Please install Ruby first"
      end
      
      unless bundle_installed?
        install_bundler 
      end

      super
    end

    def deploy
      setup
      update_code
      checkout_code
      bundle_install
      thin_restart
      link_shared_paths
      link_release
    end

    def link_shared_paths
      ssh.run("mkdir -p #{release_path('tmp')}")
      ssh.run("ln -s #{shared_path('pids')} #{release_path('tmp/pids')}")
      ssh.run("ln -s #{shared_path('log')} #{release_path('log')}")
    end

    private

    def ruby_installed?
      ssh.run("which ruby").success?
    end
  end
end