require 'shuttle/deployment/wordpress/core'
require 'shuttle/deployment/wordpress/cli'
require 'shuttle/deployment/wordpress/vip'

module Shuttle
  class Wordpress < Php
    include WordpressCli
    include WordpressCore
    include WordpressVip

    def setup
      if !config.wordpress
        error "Please add :wordpress section to your config"
      end

      super

      setup_shared_dirs
      check_dependencies
      cli_install if !cli_installed?
      core_install if !core_installed?
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

      check_plugins

      link_release
    end

    def check_dependencies
      if !svn_installed?
        log "Installing subversion"
        if ssh.run("sudo apt-get install -y subversion").success?
          log "Subversion installed"
        end
      end
    end

    def setup_shared_dirs
      ssh.run("mkdir -p #{shared_path('wp-uploads')}")
      ssh.run("mkdir -p #{shared_path('wp-core')}")
      ssh.run("mkdir -p #{shared_path('wp-plugins')}")
    end

    def generate_config
      mysql = config.wordpress.mysql
      if mysql.nil?
        error "Missing :mysql section of the config."
      end

      cmd = [
        "wp core config",
        "--dbname=#{mysql.database}",
        "--dbhost=#{mysql.host}",
        "--dbuser=#{mysql.user}",
        "--dbpass=#{mysql.password}"
      ].join(' ')

      res = ssh.run("cd #{shared_path('wp-core')} && #{cmd}")
      if res.success?
        log "A new wordpress config has been generated"
      else
        error "Unable to generate config"
      end
    end

    def check_config
      if !ssh.file_exists?(shared_path('wp-config.php'))
        log "Creating wordpress config at 'shared/wp-config.php'"
      end
    end

    def link_shared_data
      log "Linking shared data"

      ssh.run("cp -a #{shared_path('wp-core')} #{release_path}")
      #ssh.run("cp #{shared_path('wp-config.php')} #{release_path('wp-config.php')}")
      ssh.run("ln -s #{shared_path('wp-uploads')} #{release_path('wp-content/uploads')}")
    end

    def check_plugins
      plugins = config.wordpress.plugins
      if plugins
        if plugins.kind_of?(Array)
          plugins.each do |name|
            plugin_install(name)
          end
        else
          error "Config file has invalid plugins section"
        end
      end
    end

    def checkout_theme
      if config.wordpress
        if config.wordpress.theme
          checkout_code("wp-content/themes/#{config.wordpress.theme}")
        else
          error "Theme name is not defined."
        end
      else
        error "Config does not contain 'wordpress' section"
      end
    end
  end
end