module Shuttle
  class Generator
    include TerminalHelpers

    STRATEGIES = %w(static wordpress rails)

    attr_reader :strategy
    attr_reader :name, :git, :path

    def initialize(strategy='static')
      unless STRATEGIES.include?(strategy)
        raise ArgumentError, "Invalid strategy: #{strategy}"
      end

      @strategy = strategy
      @path = File.join(Dir.pwd, 'shuttle.yml')
    end

    def run
      @name = ask('Application name', :required => true)
      @git  = ask('Git repository', :required => true)

      hash = send("generate_#{strategy}")

      File.open(path, 'w') do |f|
        f.write(YAML.dump(hash))
      end

      display "New shuttle config has been generated at ./shuttle.yml"
    end

    private

    def generate_static
      {
        'app' => {
          'name' => name,
          'git'  => git
        },
        'target' => {
          'host'      => "mysite.com",
          'user'      => "deployer",
          'password'  => "password",
          'deploy_to' => "/home/deployer/#{name}"
        }
      }
    end

    def generate_wordpress
      # TODO
    end

    def generate_rails
      # TODO
    end
  end
end