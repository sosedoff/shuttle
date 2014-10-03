module Shuttle
  class Task
    def initialize(deploy, task_name, allow_failures = false)
      @deploy         = deploy
      @task_name      = task_name
      @allow_failures = allow_failures
    end

    def run
      commands = find_task_commands(@task_name)
      
      if commands.nil?
        @deploy.error("Unable to find task: #{@task_name}")
      end

      commands.each do |cmd|
        execute(@task_name, cmd, @allow_failures)
      end
    end

    private

    def find_task_commands(name)
      return unless @deploy.config.tasks.kind_of?(Hash)

      if @deploy.config.tasks[name]
        commands = [@deploy.config.tasks[name]]
        commands.flatten.compact
      end
    end

    def execute(task, cmd, allow_failures)
      @deploy.log %{Executing [task=#{task}] "#{cmd.strip}"}

      command = cmd

      if @deploy.ssh.directory_exists?(@deploy.release_path)
        command = "cd #{@deploy.release_path} && #{command}"
      end

      result = @deploy.ssh.run(command)

      if result.failure? && allow_failures == false
        @deploy.error("Failed: #{result.output}")
      else
        if !result.output.empty?
          @deploy.stream_output(result.output)
        end
      end
    end
  end
end