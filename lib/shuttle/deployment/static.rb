module Shuttle::Deployment
  class Static < Shuttle::Deployment::Base
    def execute(command)
      self.send(command.to_sym)
    end

    def deploy
      setup
      update_code
      checkout_code
      link_release
    end
  end
end