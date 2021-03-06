# encoding: UTF-8

module ThemeJuice
  module Tasks
    class VMProvision < Task

      def initialize(opts = {})
        super
      end

      def execute
        if @io.agree? "In order to finish creating your project, you need to provision the VM. Do it now?"
          provision
        else
          @io.notice "Remember, the VM needs to be provisioned before you can use your new site"
        end
      end

      def unexecute
        provision
      end

      private

      def vm_is_up?
        res = false

        @util.inside @env.vm_path do
          res = @util.run("vagrant status --machine-readable", {
            :verbose => @env.verbose, :capture => true }).include? "running"
        end

        res
      end

      def provision
        @io.log "Provisioning VM"
        @util.inside @env.vm_path do
          @util.run [] do |cmds|
            cmds << "vagrant halt" if vm_is_up?
            cmds << "vagrant up --provision"
          end
        end
      end
    end
  end
end
