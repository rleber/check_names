# frozen_string_literal: true

require_relative "check_names/version"
require 'shellwords'
require 'httparty'

module GemName
  class Error < StandardError; end

  def self.ruby_gem_exists?(name)
    response = HTTParty.get("https://rubygems.org/gems/#{name}")
    response.code == 200
  end

  def self.github_repository_exists?(name)
    github_user = `git config github.user`.chomp
    system("git ls-remote https://github.com/#{Shellwords.escape(github_user)}/#{Shellwords.escape(name)} 2>/dev/null >/dev/null")
  end

  # Note: This method does not distinguish between executables, functions, and aliases
  def self.is_executable?(name)
    system("zsh -lic 'which #{Shellwords.escape(name)}' >/dev/null")
  end

  # Note: This version explicitly excludes functions and aliases
  def self.executable_exists?(name)
    return false if self.function_exists?(name)
    return false if self.alias_exists?(name)
    self.is_executable?(name)
  end

  def self.function_exists?(name)
    test_command = <<-COMMAND
      if typeset -f #{Shellwords.escape(name)} > /dev/null; then
        return 0
      else
        return 1
      fi  
    COMMAND
    test_command_lines = test_command.split("\n")
    zsh_command = "zsh -lic '#{test_command_lines.join(';')}' >/dev/null"
    system(zsh_command)
  end

  def self.alias_exists?(name)
    system("zsh -lic 'alias #{Shellwords.escape(name)}' >/dev/null")
  end

  def self.standard_class_exists?(name)
    class_name = name.split('_').map(&:capitalize).join
    Module.const_defined?(class_name)
  end

  CHECK_METHODS = [
    {method: nil, description: "Unused"}, # 0
    {method: :ruby_gem_exists?, description: "RubyGem"}, # 1
    {method: :github_repository_exists?, description: "Github repository"}, # 2
    {method: :executable_exists?, description: "Executable"}, # 3
    {method: :function_exists?, description: "Function"}, # 4
    {method: :alias_exists?, description: "Alias"}, # 5
    {method: :standard_class_exists?, description: "Class"} # 6
  ]

  def self.unused_result
    {check: 0, description: CHECK_METHODS[0][:description], result: true}
  end

  def self.check_name_once(check, name)
    method = CHECK_METHODS[check] && CHECK_METHODS[check][:method]
    if method
      result = {check: check, description: CHECK_METHODS[check][:description], result: send(method, name)}
    else
      result = unused_result.dup
    end
    result[:name] = name
    result
  end

  def self.check_name(name)
    name = name.downcase
    result = unused_result.dup
    (1...(CHECK_METHODS.size)).each do |check|
      res = check_name_once(check, name)
      if res[:result]
        result = res
        break
      end
    end
    result[:name] = name
    result
  end

  def self.check_name_all(name)
    (1...(CHECK_METHODS.size)).map do |check|
      check_name_once(check, name)
    end
  end

  def self.check_names(*names)
    results = []
    names.each do |name|
      results << check_name(name)
    end
    results
  end

  def self.check_names_all(*names)
    results = []
    names.each do |name|
      results += check_name_all(name)
    end
    results
  end
end
