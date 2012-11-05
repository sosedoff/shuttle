module Net
  module SSH
    module SessionHelpers
      # Capture command output
      # @param command [String] command to execute
      # @return [String] command execution output
      def capture(command)
        run(command).output
      end

      # Check if remote file exists
      # @param path [String] remote file path
      # @return [Boolean]
      def file_exists?(path)
        result = capture("if [ -e #{path} ]; then echo 'true'; fi")
        result.strip == 'true'
      end

      # Check if remove process exists
      # @param pid [String] process id
      # @return [Boolean]
      def process_exists?(pid)
        result = capture("ps -p #{pid} ; true")
        result.strip.split("\n").size == 2
      end
    end
  end
end