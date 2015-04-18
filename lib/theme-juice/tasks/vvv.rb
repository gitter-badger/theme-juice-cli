# encoding: UTF-8

module ThemeJuice
  module Tasks
    class VVV < Task

      def initialize(opts = {})
        super

        runner do |tasks|
          tasks << :path
        end
      end

      def execute
        @interact.log "Running method 'execute' for #{self.class.name}"
        @tasks.each { |task| self.send "execute_#{task}" }
      end

      def unexecute
        @interact.log "Running method 'unexecute' for #{self.class.name}"
        @tasks.each { |task| self.send "unexecute_#{task}" }
      end

      private

      def execute_path
        @interact.log "Creating path"
        @io.create_file "foo.rb", "bar"
      end

      def unexecute_path
        @interact.log "Removing path"
        @io.remove_file "foo.rb", "bar"
      end
    end
  end
end
