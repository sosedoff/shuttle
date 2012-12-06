module Shuttle
  module WordpressVip
    VIP_URL = "https://vip-svn.wordpress.com/plugins/"

    def vip_path
      shared_path('wp-vip')
    end

    def vip_required?
      result = false
      res = ssh.run("cd #{release_path} && wp")
      if res.failure?
        result = res.output.include?('plugins/vip-init.php') &&
                 res.output.include?('Failed opening required')
      end
      result
    end

    def vip_installed?
      ssh.directory_exists?(vip_path)
    end

    def vip_update
      ssh.run("rm -rf #{vip_path}") if vip_installed?
      vip_install
    end

    def vip_install
      log "Installing wordpress VIP"

      vip = vip_get_config

      options = [
        "--username #{vip.user}",
        "--password #{vip.password}",
        "--non-interactive",
        VIP_URL,
        vip_path
      ].join(' ')

      cmd = "svn co #{options}"

      res = ssh.run(cmd, &method(:stream_output))

      if res.success?
        log "Wordpress VIP installed"
      else
        raise DeployError, "Unable to install wordpress VIP. Reason: #{res.output}"
      end
    end

    def vip_get_config
      data = config.original_data.wordpress.vip
      if data.nil?
       error "Please add VIP credentials to config."
      end

      if !data.user
        error "VIP user is empty. Please set :user parameter"
      end

      if !data.password
        error "VIP password is empty. Please set :password parameter"
      end

      data
    end

    def vip_link
      ssh.run("mkdir -p #{release_path}/wp-content/themes/vip")
      result = ssh.run("ln -s #{shared_path('wp-vip')} #{release_path('wp-content/themes/vip/plugins')}")
      if result.success?
        log "Wordpress VIP is linked"
      else
        error "Unable to link VIP: #{result.output}"
      end
    end
  end
end