module Shuttle
  module Tasks
    def setup
      log "Preparing application structure"

      ssh.run "mkdir -p #{deploy_path}"

      ssh.run "mkdir -p #{deploy_path('releases')}"
      ssh.run "mkdir -p #{deploy_path('backups')}"
      ssh.run "mkdir -p #{deploy_path('shared')}"

      ssh.run "mkdir -p #{shared_path('tmp')}"
      ssh.run "mkdir -p #{shared_path('pids')}"
      ssh.run "mkdir -p #{shared_path('log')}"
    end

    def deploy
      setup
      update_code
      checkout_code
      link_release
      cleanup_releases
    end

    def keep_releases
      5
    end

    def update_code
      if !git_installed?
        error "Git is not installed"
      end

      if config.app.git.nil?
        error "Git source url is not defined. Please define :git option first"
      end

      if ssh.directory_exists?(deploy_path('scm'))
        log "Updating to the latest code"
        ssh.run "cd #{deploy_path('scm')} && git pull"
      else
        log "Getting latest code" 
        res = ssh.run "cd #{deploy_path} && git clone --depth 10 --recursive --quiet #{config.app.git} scm"
        if res.failure?
          error "Unable to get code. Reason: #{res.output}"
        end
      end
    end

    def checkout_code(path=nil)
      log "Checking out latest code"

      checkout_path = [release_path, path].compact.join('/')
      res = ssh.run("cd #{deploy_path('scm')} && git checkout-index -f -a --prefix=#{checkout_path}/")
      
      if res.failure?
        error "Failed to checkout code. Reason: #{res.output}"
      end
    end

    def link_release
      if !release_exists?
        error "Release does not exist"
      end

      log "Linking release"

      if ssh.run("unlink #{current_path}").failure?
        ssh.run("rm #{current_path}")
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

    def cleanup_release
      if ssh.directory_exists?(release_path)
        ssh.run("rm -rf #{release_path}")
      end
    end

    def cleanup_releases
      ssh.run("cd #{deploy_path('releases')}")
      ssh.run("count=`ls -1d [0-9]* | sort -rn | wc -l`")
      ssh.run("remove=$((count > 5 ? count - #{keep_releases} : 0))}")
      ssh.run("ls -1d [0-9]* | sort -rn | tail -n $remove | xargs rm -rf {}")
    end

    def write_revision
      if ssh.directory_exists?(deploy_path('scm'))
        ssh.run("cd #{deploy_path('scm')} && git log --format='%H' -n 1 > #{release_path}/REVISION")
      end
    end

    def deploy_running?
      ssh.file_exists?("#{deploy_path}/.lock")
    end

    def connect
      exec("ssh #{target.user}@#{target.host}")
    end
  end
end