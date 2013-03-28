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
  end
end