module Shuttle
  class Deploy
    include Shuttle::Helpers
    include Shuttle::PathHelpers

    attr_reader :ssh
    attr_reader :target
    attr_reader :environment
    attr_reader :version
    attr_reader :config

    def initialize(config, ssh, target, environment)
      @config      = config
      @target      = target
      @ssh         = ssh
      @environment = environment

      if ssh.file_exists?(version_path)
        res = ssh.capture("cat #{version_path}")
        @version = (res.empty? ? 1 : Integer(res) + 1).to_s
      else
        @version = 1
      end
    end

    # Get current deploy version
    # @return [Integer]
    def last_version
      @last_version ||= ssh.read_file(version_path).to_i
    end

    # Get list of all existing releases
    # @return [Array<Integer>]
    def available_releases
      if ssh.directory_exists?(deploy_path('releases'))
        releases = ssh.capture("ls --color=never #{deploy_path}/releases")

        releases.
          scan(/[\d]+/).
          map { |s| s.strip.to_i }.
          sort
      else
        []
      end
    end
  end
end