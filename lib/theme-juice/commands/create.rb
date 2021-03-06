# encoding: UTF-8

module ThemeJuice
  module Commands
    class Create < Command

      THEMES = {
        "theme-juice/trellis" => "git@github.com:ezekg/theme-juice-starter.git",
        "wordpress/wordpress" => "git@github.com:WordPress/WordPress.git",
        "other (specify)"     => nil,
        "none"                => false
      }

      def initialize(opts = {})
        super

        init_project

        runner do |tasks|
          tasks << Tasks::CreateConfirm.new
          tasks << Tasks::Location.new
          tasks << Tasks::Theme.new
          tasks << Tasks::VMBox.new
          tasks << Tasks::VMPlugins.new
          tasks << Tasks::VMLocation.new
          tasks << Tasks::VMCustomfile.new
          tasks << Tasks::Database.new
          if @env.nginx
            tasks << Tasks::Nginx.new
          else
            tasks << Tasks::Apache.new
          end
          tasks << Tasks::DotEnv.new
          tasks << Tasks::Landrush.new
          tasks << Tasks::ForwardPorts.new
          tasks << Tasks::SyncedFolder.new
          tasks << Tasks::DNS.new
          tasks << Tasks::WPCLI.new
          tasks << Tasks::Repo.new
          tasks << Tasks::VMProvision.new
          tasks << Tasks::ImportDatabase.new
          tasks << Tasks::CreateSuccess.new
        end
      end

      private

      def init_project
        @project.use_defaults = @opts.fetch("use_defaults") { false }
        @project.bare         = @opts.fetch("bare")         { false }
        @project.skip_repo    = @opts.fetch("skip_repo")    { false }
        @project.skip_db      = @opts.fetch("skip_db")      { false }
        @project.no_wp        = @opts.fetch("no_wp")        { false }
        @project.no_db        = @opts.fetch("no_db")        { false }
        @project.name         = @opts.fetch("name")         { name }
        @project.location     = @opts.fetch("location")     { location }
        @project.url          = @opts.fetch("url")          { url }
        @project.xip_url      = @opts.fetch("xip_url")      { xip_url }
        @project.theme        = @opts.fetch("theme")        { theme }
        @project.repository   = @opts.fetch("repository")   { repository }
        @project.db_host      = @opts.fetch("db_host")      { db_host }
        @project.db_name      = @opts.fetch("db_name")      { db_name }
        @project.db_user      = @opts.fetch("db_user")      { db_user }
        @project.db_pass      = @opts.fetch("db_pass")      { db_pass }
        @project.db_import    = @opts.fetch("db_import")    { db_import }
      end

      def name
        if @env.yolo
          name = Faker::Internet.domain_word
        else
          name = @io.ask "What's the project name? (letters, numbers and dashes only)"
        end

        valid_name? name

        name
      end

      def valid_name?(name)
        if name.empty?
          @io.error "Project name '#{name}' looks like it's empty. Aborting mission."
        end

        "#{name}".match /[^0-9A-Za-z.\-]/ do |char|
          @io.error "Project name contains an invalid character '#{char}'. This name is used internally for a ton of stuff, so that's not gonna work. Aborting mission."
        end

        true
      end

      def clean_name
        "#{@project.name}".gsub(/[^\w]/, "_")[0..10]
      end

      def location
        path = "#{Dir.pwd}/"

        if @project.use_defaults
          location = File.expand_path path + @project.name
        else
          location = File.expand_path @io.ask("Where do you want to setup the project?", :default => path, :path => true)
        end

        location
      end

      def url
        if @project.use_defaults
          url = "#{@project.name}.dev"
        else
          url = @io.ask "What do you want the development url to be? (this should end in '.dev')", :default => "#{@project.name}.dev"
        end

        valid_url? url

        url
      end

      def valid_url?(url)
        unless "#{url}".match /(.dev)$/
          @io.error "Your development url '#{url}' doesn't end with '.dev'. This is used internally by Landrush, so that's not gonna work. Aborting mission."
        end

        true
      end

      def xip_url
        xip_url = @project.url.gsub /\.dev$/, ""

        xip_url
      end

      def theme
        return false if @project.bare

        if @project.use_defaults
          theme = THEMES["theme-juice/trellis"]
        else
          choice = @io.choose "Which starter theme would you like to use?", :blue, THEMES.keys

          case choice
          when /(theme-juice)/
            @io.say "Awesome choice!", :color => :green, :icon => :success
          when /(wordpress)/
            @io.say "This is a stock WordPress install, so things such as the '.env' file will not be set up. You'll need to input your database information manually after the setup.", {
              :color => :yellow, :icon => :notice }
          when /(other)/
            THEMES[choice] = @io.ask "What is the repository URL of the starter theme that you would like to clone?"
          when /(none)/
            @project.bare = true
            @io.say "Next time you need to create a project without a starter theme, you can just run the 'setup' command instead.", {
              :color => :yellow, :icon => :notice }
          end

          theme = THEMES[choice]
        end

        theme
      end

      def repository
        return false if @project.skip_repo || @project.use_defaults

        if @io.agree? "Would you like to initialize a new Git repository?"
          repo = @io.ask "What is the repository URL?", :indent => 2
        else
          repo = false
        end

        repo
      end

      %w[host name user pass].each do |task|
        define_method "db_#{task}" do
          return false if @project.no_db || @project.no_wp

          default = case task
                    when "host" then "vvv"
                    when "name" then "#{clean_name}_db"
                    when "user" then "#{clean_name}_user"
                    when "pass" then Faker::Internet.password(24)
                    end

          if @project.skip_db || @project.use_defaults
            res = default
          else
            res = @io.ask "Database #{task}", :default => default
          end

          res
        end
      end

      def db_import
        return false if @project.no_db || @project.no_wp || @project.use_defaults

        if @io.agree? "Would you like to import an existing database?"
          db = @io.ask "Where is the database file?", {
            :indent => 2, :path => true }
        else
          db = false
        end

        db
      end
    end
  end
end
