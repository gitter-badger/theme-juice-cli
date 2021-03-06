# encoding: UTF-8

module ThemeJuice
  module Config
    @env     = Env
    @io      = IO
    @project = Project
    @util    = Util.new

    def command(sequence, *args)
      begin
        config.commands.fetch("#{sequence}") {
          @io.error "Command '#{sequence}' not found in config", NotImplementedError }
          .each { |c| run format_command(c, *args) }
      rescue NoMethodError
        @io.say "Skipping...", :color => :yellow, :icon => :notice
      end
    end

    def deployment
      config.deployment ||
        @io.error("Deployment settings not found in config", NotImplementedError)
    end

    private

    def run(command)
      @util.inside @project.location do
        @util.run command, { :verbose => @env.verbose,
          :capture => @env.quiet }
      end
    end

    def format_command(cmd, args = [])
      if multi_arg_regex =~ cmd
        cmd.gsub! multi_arg_regex, args.join(" ")
      else
        args.to_enum.with_index(1).each do |arg, i|
          cmd.gsub! single_arg_regex(i), arg
        end
      end
      cmd
    end

    def config
      begin
        @project.location ||= Dir.pwd

        YAML.load_file Dir["#{@project.location}/*"].select { |f|
          config_regex =~ File.basename(f) }.last ||
          @io.error("Config file not found in '#{@project.location}'", LoadError)
      rescue ::Psych::SyntaxError => err
        @io.error "Config file contains invalid YAML", SyntaxError do
          puts err
        end
      rescue LoadError, SystemExit
        nil
      end
    end

    def config_regex
      %r{^(((\.)?(tj)|((J|j)uicefile))(\.y(a)?ml)?$)}
    end

    def multi_arg_regex
      %r{(%args%)|(%arguments%)}
    end

    def single_arg_regex(i)
      %r{(%arg#{i}%)|(%argument#{i}%)}
    end

    extend self
  end
end
