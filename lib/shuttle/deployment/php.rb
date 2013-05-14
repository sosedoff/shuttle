module Shuttle
  class Php < Shuttle::Deploy
    def setup
      unless php_installed?
        error "Please install PHP first"
      end

      super
    end

    private

    def php_installed?
      ssh.run("which php").success?
    end
  end
end