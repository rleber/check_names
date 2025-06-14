
# frozen_string_literal: true

require_relative "lib/check_names/version"

Gem::Specification.new do |spec|
  gem_name = File.basename(__dir__)
  puts "gem_name = #{gem_name}"
  spec.name = gem_name
  class_name = gem_name.split('_').map(&:capitalize).join
  spec.version = eval("#{class_name}::VERSION")
  spec.authors = ["Richard LeBer"]
  spec.email = ["richard.leber@gmail.com"]
  spec.date = %q{2025-06-14}
  
  spec.summary = %q{Check whether names are in use}
  spec.description = spec.summary
  github_username = `git config github.user`.chomp
  spec.homepage = %Q{http://github.com/#{github_username}/#{spec.name}}
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"
  spec.rdoc_options = ['--charset=UTF-8', "--main", "README.md"]
  spec.rdoc_options << '--title' <<  'rleber check_names library'
  spec.rdoc_options << '--line-numbers' << '--inline-source'

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  spec.metadata["changelog_uri"] = spec.homepage + "/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .envrc .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.rubygems_version = ">= 3.6.9"

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end

