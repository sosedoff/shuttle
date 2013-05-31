require 'shuttle/deployment/wordpress/core'
require 'shuttle/deployment/wordpress/cli'
require 'shuttle/deployment/wordpress/vip'
require 'shuttle/deployment/wordpress/plugins'

module Shuttle
  class Wordpress < Php
    include WordpressCli
    include WordpressCore
    include WordpressVip
    include WordpressPlugins

    def setup
      if config.wordpress.nil?
        error "Please add :wordpress section to your config"
      end

      super

      setup_shared_dirs
      check_dependencies

      if !cli_installed?
        cli_install
      else
        version = ssh.capture("cd #{core_path} && wp --version")
        version.gsub!('wp-cli', '').strip!
        log "Wordpress CLI version: #{version}"
      end

      if !core_installed?      
        core_install
      else
        version = ssh.capture("cd #{core_path} && wp core version")
        log "Wordpress core version: #{version}"
      end

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

      if !site_installed?
        site_install
        network_install
      end

      check_plugins
      activate_theme

      link_release
    end

    def check_dependencies
      if !svn_installed?
        log "Installing Subversion"
        if ssh.run("sudo apt-get install -y subversion").success?
          log "Subversion installed"
        end
      end
    end

    def setup_shared_dirs
      dirs = [
        'wordpress',
        'wordpress/uploads',
        'wordpress/core',
        'wordpress/plugins'
      ]

      dirs.each do |path|
        ssh.run("mkdir -p #{shared_path(path)}")
      end
    end

    def generate_config
      mysql = config.wordpress.mysql
      if mysql.nil?
        error "Missing :mysql section of the config."
      end

      cmd = [
        "wp core config",
        "--dbname=#{mysql.database}",
        "--dbhost=#{mysql.host || 'localhost'}",
        "--dbuser=#{mysql.user}"
      ]

      cmd << "--dbpass=#{mysql.password}" if mysql.password

      res = ssh.run("cd #{core_path} && #{cmd.join(' ')}")
      if res.success?
        log "A new wordpress config has been generated"
      else
        error "Unable to generate config. Error: #{res.output}"
      end
    end

    def check_config
      if !ssh.file_exists?(shared_path('wordpress/core/wp-config.php'))
        log "Creating wordpress config"
        generate_config
      end
    end

    def site_installed?
      ssh.run("cd #{release_path} && wp").success?
    end

    def site_install
      if config.wordpress.site
        site = config.wordpress.site

        cmd = [
          "wp core install",
          "--url=#{site.url}",
          "--title=#{site.title}",
          "--admin_name=#{site.admin_name}",
          "--admin_email=#{site.admin_email}",
          "--admin_password=#{site.admin_password}"
        ].join(' ')

        result = ssh.run("cd #{release_path} && #{cmd}")
        if result.failure?
          error "Failed to setup site. #{result.output}"
        end
      else
        error "Please define :site section"
      end
    end

    def network_install
      if config.wordpress.network
        network = config.wordpress.network

        cmd = [
          "wp core install-network",
          "--title=#{network.title}",
        ].join(' ')

        result = ssh.run("cd #{release_path} && #{cmd}")
        if result.failure?
          error "Failed to setup WP network. #{result.output}"
        end
      end
    end

    def link_shared_data
      log "Linking shared data"

      ssh.run("cp -a #{core_path} #{release_path}")
      ssh.run("cp #{shared_path('wp-config.php')} #{release_path('wp-config.php')}")
      ssh.run("ln -s #{shared_path('wordpress/uploads')} #{release_path('wp-content/uploads')}")
    end

    def check_plugins
      plugins = config.wordpress.plugins

      if plugins
        if plugins.kind_of?(Array)
          plugins.each do |p|
            if p.kind_of?(String)
              plugin_install(p)
            elsif p.kind_of?(Hash)
              name, url = p.to_a.flatten.map(&:to_s)
              plugin_custom_install(name, url)
            end
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

    def activate_theme
      name = config.wordpress.theme
      result = ssh.run("cd #{release_path} && wp theme activate #{name}")

      if result.failure?
        error "Unable to activate theme. Error: #{result.output}"
      end
    end
  end
end