module Shuttle
  module Helpers
    def log(message, level='info')
      puts "-----> #{message}"
    end

    def error(message)
      log("ERROR: #{message}", 'error')
      raise DeployError, message
    end

    def git_installed?
      ssh.run("which git").success?
    end

    def svn_installed?
      ssh.run("which svn").success?
    end

    def release_exists?
      ssh.directory_exists?(release_path)
    end

    def stream_output(buff)
      str = buff.split("\n").map { |str| "       #{str}"}.join("\n")
      puts str
    end
  end
end