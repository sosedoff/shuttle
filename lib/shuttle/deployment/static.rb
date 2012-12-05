module Shuttle
  class Static < Shuttle::Deploy
    def deploy
      setup
      update_code
      checkout_code
      link_release
    end
  end
end