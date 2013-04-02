module Shuttle
  module WordpressPlugins
    # Install wordpresss plugin
    # @param [String] plugin name slug
    def plugin_install(name)
      log "Installing plugin: #{name}"

      res = ssh.run("cd #{release_path} && wp plugin install #{name}")
      if !res.success?
        error "Unable to install plugin '#{name}'. Reason: #{res.output}"
      end
    end

    def plugin_custom_install(name, url)
      log "Installing custom plugin: #{name} -> #{url}"

      if git_url?(url)
        install_git_plugin(name, url)
      elsif file_url?(url)
        install_file_plugin(name, url)
      else
        error "Valid git URL or archive URL is required for plugin: #{name}"
      end
    end

    # Check if wordpress plugin is installed
    # @return [Boolean]
    def plugin_installed?(name)
      raise "Not Implemented"
    end

    private

    # Check if provided plugin url is a git repository
    # @return [Boolean]
    def git_url?(url)
      url.include?('.git') || url.include?('git@') || url.include?('git://')
    end

    # Check if provided plugin url is a file
    # @return [Boolean]
    def file_url?(url)
      name = File.basename(url)
      name.include?('.zip') || name.include?('.tar.gz')
    end

    def install_git_plugin(plugin_name, url)
      ssh.run "cd #{release_path}/wp-content/plugins"
      res = ssh.run "git clone #{url} #{plugin_name}"

      if res.failure?
        error "Unable to install plugin '#{plugin_name}'. Reason: #{res.output}"
      end

      # Cleanup git folder
      ssh.run("rm -rf #{release_path}/wp-content/plugins/#{plugin_name}/.git")
    end

    def install_file_plugin(plugin_name, url)
      name = File.basename(url)
      plugin_path = "#{release_path}/wp-content/plugins/"

      if ssh.file_exists?("/tmp/#{name}")
        ssh.run("rm -f /tmp/#{name}")
      end

      # Download file first
      log "Downloading #{url}"
      result = ssh.run("cd /tmp && wget #{url}")

      if result.failure?
        error "Unable to download file from #{url}"
      end

      log "Extracting #{name} to plugins directory"

      if name.include?('.zip')
        check_unzip

        if ssh.run("unzip /tmp/#{name} -d #{plugin_path}").failure?
          error "Unable to extract plugin"
        end
      elsif name.include?('.tar.gz')
        if ssh.run("tar -xzf #{name} -C #{plugin_path}").failure?
          error "Unable to extract plugin"
        end
      end
    end

    def check_unzip
      if ssh.run("which unzip").failure?
        log "Unzip utility is missing. Installing..."

        ssh.run("sudo apt-get update")
        if ssh.run("sudo apt-get -y install unzip").failure?
          error "Unable to install unzip utility"
        end
      end
    end
  end
end