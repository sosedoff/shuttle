module Shuttle
  class Static < Shuttle::Deploy
    def deploy
      setup
      update_code
      checkout_code

      if config.before_link_release
        execute_commands(config.before_link_release)
      end

      link_release
    end
  end
end