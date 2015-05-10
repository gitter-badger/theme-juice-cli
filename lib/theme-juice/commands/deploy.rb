# encoding: UTF-8

module ThemeJuice
  module Commands
    class Deploy < Command

      def initialize(opts = {})
        super

        @project.vm_root     = vm_root
        @project.vm_location = vm_location
        @project.vm_srv      = vm_srv

        runner do |tasks|
          @io.error "Not implemented"
        end
      end
    end
  end
end