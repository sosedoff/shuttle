module Shuttle
  class Php < Shuttle::Deploy
    def setup
      if !php_installed?
        error "PHP is not installed on this system"
      end
      
      super
    end

    def php_installed?
      ssh.run("which php").success?
    end
  end
end