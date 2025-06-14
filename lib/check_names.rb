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

  def self.check(name)
    name = name.downcase
    if ruby_gem_exists?(name)
      return {rc: 1, message: "A Gem on RubyGems"}
    end
    if github_repository_exists?(name)
      return {rc: 2, message: "A personal Github repository"}
    end
    if executable_exists?(name)
      return {rc: 3, message: "An executable"}
    end
    if function_exists?(name)
      return {rc: 4, message: "A function"}
    end
    if alias_exists?(name)
      return {rc: 5, message: "An alias"}
    end
    {rc: 0, message: "Available"}
  end
end
