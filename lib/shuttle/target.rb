module Shuttle
  class Target
    attr_reader :host, :user, :password
    attr_reader :deploy_to

    def initialize(hash)
      @host      = hash[:host]
      @user      = hash[:user]
      @password  = hash[:password]
      @deploy_to = hash[:deploy_to]
    end

    def connection
      @connection ||= Net::SSH::Session.new(host, user, password)
    end

    def validate!
      raise Shuttle::ConfigError, "Host required" if host.nil?
      raise Shuttle::ConfigError, "User required" if user.nil?
      raise Shuttle::ConfigError, "Deploy path required" if deploy_to.nil?
    end
  end
end