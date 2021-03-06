# encoding: UTF-8

lib = File.expand_path "../lib/", __FILE__
$:.unshift lib unless $:.include? lib

require "theme-juice/version"

Gem::Specification.new do |gem|
  gem.name           = "theme-juice"
  gem.version        = ::ThemeJuice::VERSION
  gem.authors        = ["Ezekiel Gabrielse"]
  gem.email          = ["ezekg@yahoo.com"]
  gem.description    = %q{Theme Juice (tj) is a command line utility for modern WordPress development. It allows you to scaffold out a Vagrant development environment in seconds, and generate/manage an unlimited number of development projects. It also helps you manage dependencies and build tools, and can even handle your deployments.}
  gem.summary        = %q{WordPress development made easy}
  gem.homepage       = "http://themejuice.it"

  gem.licenses       = "GPLv2"

  gem.files          = Dir.glob "lib/**/*.*"
  gem.files         += Dir.glob "lib/theme-juice/man/**/*"
  gem.files         += ["README.md"]
  gem.test_files     = gem.files.grep %r{^(test|spec|features)/}
  gem.executables    = ["tj"]
  gem.require_paths  = ["lib"]

  gem.required_ruby_version = ">= 1.9.3"

  gem.add_runtime_dependency "thor",                     "~> 0.19.0"
  gem.add_runtime_dependency "faker",                    "~> 1.4.0"
  gem.add_runtime_dependency "os",                       "~> 0.9.0"
  gem.add_runtime_dependency "capistrano",               "~> 3.4.0"
  gem.add_runtime_dependency "capistrano-slackify",      "~> 2.4.0"
  gem.add_runtime_dependency "capistrano-rsync-bladrak", "~> 1.3.2"

  gem.add_development_dependency "bundler", "~> 1.0"
  gem.add_development_dependency "rake",    "~> 10.4"
end
