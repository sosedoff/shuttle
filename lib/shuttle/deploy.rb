module Shuttle
  class Deploy
    attr_reader :config, :target

    def initialize(config, target)
      @config = config
      @target = target
    end

    def execute(command)
      session = ssh_session(@target)
      session.open

      klass = Shuttle::Deployment.const_get(@config.app_type.capitalize)
      integration = klass.new(@config, @target, session)

      unless integration.respond_to?(:execute)
        raise RuntimeError, "Execution method should be defined"
      end

      integration.execute(command)

      session.close
    end

    # Initialize a new session instance
    # @param target [DeployConfig::Target] target environment
    # @return [Net::SSH::Session] ssh session for target host
    def ssh_session(target)
      session = Net::SSH::Session.new(target.host, target.user, target.password)
      session.logger = Net::SSH::SessionLogger.new(STDOUT)
      session
    end
  end
end