module Shuttle
  class Deploy
    include Shuttle::Tasks
    include Shuttle::Helpers

    attr_reader :ssh
    attr_reader :target
    attr_reader :environment
    attr_reader :version
    attr_reader :config

    def initialize(config, ssh, target, environment)
      @config = config
      @target = target
      @ssh = ssh
      @environment = environment

      if ssh.file_exists?(version_path)
        res = ssh.capture("cat #{version_path}")
        @version = (res.empty? ? 1 : Integer(res) + 1).to_s
      else
        @version = 1
      end
    end

    def deploy_path(path=nil)
      [target.deploy_to, path].compact.join('/')
    end

    def shared_path(path=nil)
      [deploy_path, 'shared', path].compact.join('/')
    end

    def current_path(path=nil)
      [deploy_path, 'current', path].compact.join('/')
    end

    def version_path
      deploy_path('version')
    end

    def release_path(path=nil)
      [deploy_path, 'releases', version, path].compact.join('/')
    end
  end
end