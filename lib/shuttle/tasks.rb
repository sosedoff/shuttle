module Shuttle
  module Tasks
    def log(message, level='info')
      if level == 'error'
        puts "-----> #{message}".red
      else
        puts "----->".green + " #{message}"
      end
    end

    def setup
      log "Preparing application structure"
      ssh.run "mkdir -p #{deploy_path}"
      %w(releases shared backups tmp).each do |dir|
        ssh.run "mkdir -p #{deploy_path(dir)}"
      end
    end

    def deploy
      raise "Implementation Needed"
    end

    def update_code
      if ssh.directory_exists?(deploy_path('scm'))
        log "Updating to the latest code"
        ssh.run "cd #{deploy_path('scm')} && git pull"
      else
        log("Getting latest code")
        res = ssh.run "cd #{deploy_path} && git clone --depth 10 --recursive --quiet #{config.git} scm"
        if res.failure?
          error "Failed to fetch code. Output: #{res.output}"
        end
      end
    end

    def checkout_code(path=nil)
      log "Checking out latest code"
      checkout_path = [release_path, path].compact.join('/')
      res = ssh.run("cd #{deploy_path('scm')} && git checkout-index -f -a --prefix=#{checkout_path}/")
      
      if res.failure?
        error "Failed to checkout code. Output: #{res.output}"
      end
    end

    def link_release
      log "Linking release..."
      if ssh.directory_exists?(current_path)
        ssh.run "unlink #{current_path}"
      end

      ssh.run "ln -s #{release_path} #{current_path}"
      ssh.run "echo #{version} > #{version_path}"

      log "Release v#{version} has been deployed"
    end

    def write_lock
      ssh.run("touch #{deploy_path}/.lock")
    end

    def release_lock
      ssh.run("rm #{deploy_path}/.lock")
    end

    def rollback
      if ssh.directory_exists?(release_path)
        ssh.run("rm -rf #{release_path}")
      end
    end

    def deploy_running?
      ssh.file_exists?("#{deploy_path}/.lock")
    end

    def write_revision
      if ssh.directory_exists?(deploy_path('scm'))
        ssh.run("cd #{deploy_path('scm')} && git log --format='%H' -n 1 > #{release_path}/REVISION")
      end
    end
  end
end