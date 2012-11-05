require 'logger'

module Net
  module SSH
    class SessionLogger
      attr_reader :logger

      def initialize(target=STDOUT)
        @logger = Logger.new(STDOUT)
      end

      def log_command(command)
        message = "Command: #{command.command}, Exit Code: #{command.exit_code}"
        logger.info(message)
      end
    end
  end
end