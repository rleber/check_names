
github_username = 'rleber'

Gem::Specification.new do |s|
  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.name = 'check_names'
  s.authors = ["Richard LeBer"]
  s.email = "richard.leber@gmail.com"
  s.version = File.read(File.join(__dir__,'VERSION.txt')).chomp
  s.date = %q{2025-06-14}
  s.description = %q{Check whether names are in use}
  s.executables = `git ls-files -- exe/*`.split("\n").map{ |f| File.basename(f) }
  s.test_files = `git ls-files -- {spec,test}/*`.split("\n")
  s.homepage = %Q{http://github.com/#{github_username}/#{s.name}}
  s.rdoc_options = ['--charset=UTF-8', "--main", "README.md"]
  s.rdoc_options << '--title' <<  'rleber check_names library'
  s.rdoc_options << '--line-numbers' << '--inline-source'
  s.rubygems_version = %q{1.3.6}
  s.summary = s.description
  s.files = `git ls-files -- {bin,lib,spec,test}/*`.split("\n")
  s.require_paths = ["lib"]
  s.rubygems_version = %q{3.1.4}
  s.license = 'MIT'
end

