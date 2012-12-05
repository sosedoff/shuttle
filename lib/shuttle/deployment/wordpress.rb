require 'shuttle/deployment/wordpress/core'
require 'shuttle/deployment/wordpress/cli'
require 'shuttle/deployment/wordpress/vip'

module Shuttle
  class Wordpress < Deploy
    include WordpressCli
    include WordpressCore
    include WordpressVip

    def setup
      if !config.original_data.wordpress
        error "Wordpress section of config is not defined"
      end

      super

      setup_shared_dirs
      check_dependencies
      install_cli if !cli_installed?
      install_core if !core_installed?
      check_config
    end

    def deploy
      setup
      update_code
      link_shared_data
      checkout_theme

      if vip_required?
        vip_install if !vip_installed?
        vip_link
      end

      link_release
    end

    def check_dependencies
      log "Checking dependencies..."

      if ssh.run("which svn").failure?
        log "Subversion is missing. Installing..."
        if ssh.run("sudo apt-get install -y subversion").success?
          log "Subversion is installed"
        end
      else
        log "Subversion is already installed"
      end
    end

    def setup_shared_dirs
      ssh.run("mkdir -p #{shared_path('wp-uploads')}")
      ssh.run("mkdir -p #{shared_path('wp-core')}")
    end

    def check_config
      if !ssh.file_exists?(shared_path('wp-config.php'))
        error "Config is missing at 'shared/wp-config.php'. Please create it first."
      end
    end

    def link_shared_data
      log "Linking shared data"

      ssh.run("cp -a #{shared_path('wp-core')} #{release_path}")
      ssh.run("cp #{shared_path('wp-config.php')} #{release_path('wp-config.php')}")
      ssh.run("ln -s #{shared_path('wp-uploads')} #{release_path('wp-content/uploads')}")
    end

    def checkout_theme
      if config.original_data.wordpress
        if config.original_data.wordpress.theme
          checkout_code("wp-content/themes/#{config.original_data.wordpress.theme}")
        else
          error "Theme name is not defined."
        end
      else
        error "Config does not contain 'wordpress' section"
      end
    end
  end
end