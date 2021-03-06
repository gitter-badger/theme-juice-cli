# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Load < Task

      def initialize
        super
      end

      def execute
        load_capistrano
        load_tasks
      end

      private

      def load_capistrano
        @io.log "Loading Capistrano"

        require "capistrano/setup"
        require "capistrano/deploy"
        require "capistrano/rsync"
        require "capistrano/slackify" if @config.deployment.key? "slack"
        require "capistrano/framework"
      end

      def load_tasks
        @io.log "Loading Capistrano tasks"

        tasks_dir = "#{File.dirname(__FILE__)}/capistrano"
        tasks     = %w[db uploads env rsync]

        tasks.each { |task| load "#{tasks_dir}/#{task}.rb" }
      end
    end
  end
end
