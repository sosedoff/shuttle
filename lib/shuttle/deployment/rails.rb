module Shuttle
  class Rails < Shuttle::Strategy
    include Shuttle::Support::Bundler
    include Shuttle::Support::Thin

    def rails_env
      if config.rails && config.rails.environment
        config.rails.environment
      else
        environment
      end
    end

    def precompile_assets?
      config.rails && config.rails.precompile_assets != false
    end

    def cache_assets?
      config.rails && config.rails.cache_assets == true
    end

    def start_server?
      if config.rails && !config.rails.start_server.nil?
        config.rails.start_server
      else
        true
      end
    end

    def setup_bundler
      if !bundler_installed?
        log "Bundler is missing. Installing"

        res = ssh.run("sudo gem install bundler")
        if res.success?
          log "Bundler v#{bundler_version} installed"
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

    # Precompile rails assets. If no changes detected between last and 
    # current releases, precompile task will be skipped.
    def precompile_assets
      if precompile_assets?
        precompile = true

        # Detect if there any change in assets
        if cache_assets? && last_version != version
          old_path = deploy_path("releases/#{last_version}")
          new_path = release_path

          result = ssh.run("diff -arq #{old_path}/app/assets #{new_path}/app/assets")
          if result.success?
            precompile = false
            ssh.run("cp -a #{old_path}/public/assets #{new_path}/public/")
          end
        end

        if precompile
          log "Precompiling assets"
          rake 'assets:precompile'
        else
          log "Asset procompilation skipped"
        end
      end
    end

    def deploy
      ssh.export('RACK_ENV', rails_env)
      ssh.export('RAILS_ENV', rails_env)

      log "Rails environment is set to #{rails_env}"

      setup
      setup_bundler
      update_code
      checkout_code
      bundle_install
      migrate_database
      precompile_assets
      link_shared_paths
      
      if start_server?
        thin_restart
      end

      link_release
      cleanup_releases
    end

    def migrate_database
      return if !ssh.file_exists?(release_path('db/schema.rb'))

      migrate     = true # Will migrate by default
      schema      = ssh.read_file(release_path('db/schema.rb'))
      schema_file = shared_path('schema')
      checksum    = Digest::SHA1.hexdigest(schema)

      if ssh.file_exists?(schema_file)
        old_checksum = ssh.read_file(schema_file).strip
        if old_checksum == checksum
          migrate = false
        end
      end

      if migrate == true
        log "Migrating database"
        rake 'db:migrate'
        ssh.run("echo #{checksum} > #{schema_file}")
      else
        log "Database migration skipped"
      end
    end

    def link_shared_paths
      ssh.run("mkdir -p #{release_path('tmp')}")
      ssh.run("rm -rf #{release_path}/log")
      ssh.run("ln -s #{shared_path('pids')} #{release_path('tmp/pids')}")
      ssh.run("ln -s #{shared_path('log')} #{release_path('log')}")

      if config.rails
        if config.rails.shared_paths
          config.rails.shared_paths.each_pair do |name, path|
            if ssh.directory_exists?("#{shared_path}/#{name}")
              log "Linking shared path: #{name}"
              ssh.run("ln -s #{shared_path}/#{name} #{release_path}/#{path}")
            else
              error "Shared path does not exist: #{shared_path}/#{name}"
            end
          end
        end
      end
    end
  end
end