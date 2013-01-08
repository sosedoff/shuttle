module Shuttle
  class Rails < Shuttle::Deploy
    include Shuttle::Support::Bundler
    include Shuttle::Support::RVM
    include Shuttle::Support::Thin

    def rails_env
      ''
    end

    def setup_bundler
      if !bundler_installed?
        info "Bundler is missing. Installing"
        rer = ssh.run("gem install bundler")
        if res.success?
          info "Bundler v#{bundler_version} installed"
        else
          error "Unable to install bundler: #{res.output}"
        end
      end
    end

    def rake(command)
      res = ssh.run("cd #{release_path} && rake #{command}")
      if res.failure?
        error "Unable to run rake command: #{command}. Reason: #{res.output}"
      end
    end

    def deploy
      ssh.export('RACK_ENV', environment)
      ssh.export('RAILS_ENV', environment)

      setup
      setup_bundler
      update_code
      checkout_code
      bundle_install

      log "Migrating database"
      rake 'db:migrate'

      log "Precompiling assets"
      rake 'assets:precompile'
      
      thin_restart

      link_shared_paths
      link_release
    end

    def link_shared_paths
      ssh.run("mkdir -p #{release_path('tmp')}")
      ssh.run("ln -s #{shared_path('pids')} #{release_path('tmp/pids')}")
      ssh.run("ln -s #{shared_path('log')} #{release_path('log')}")
    end
  end
end