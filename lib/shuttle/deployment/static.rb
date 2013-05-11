module Shuttle
  class Static < Shuttle::Deploy
    def deploy
      setup

      update_code
      checkout_code

      execute_hook(:before_link_release)
      link_release
      execute_hook(:after_link_release)

      cleanup_releases
    end
  end
end