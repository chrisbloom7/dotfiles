# brew_info.rb
# Looks up one or more Homebrew package names via `brew info --json=v2` and
# returns structured data about each package.
#
# Usage (as a library):
#   require_relative 'brew_info'
#   packages = BrewInfo.lookup(%w[git fzf])
#   # => [{ name: "git", type: "brew", description: "..." }, ...]
#
# Not executable — called via `require_relative` from brew_add, brew_remove,
# and brew_audit.

require 'json'
require 'open3'

class BrewInfo
  BREW_ENV = {
    'HOMEBREW_NO_AUTO_UPDATE' => '1',
    'HOMEBREW_NO_ENV_HINTS'   => '1'
  }.freeze

  # Looks up one or more package names.
  # Returns an array of hashes: [{ name:, type:, description: }, ...]
  # Raises RuntimeError on brew command failure or if a name is not found.
  def self.lookup(names)
    names = Array(names)
    raise ArgumentError, 'At least one package name is required' if names.empty?

    cmd = ['brew', 'info', '--quiet', '--json=v2'] + names
    stdout, stderr, status = Open3.capture3(BREW_ENV, *cmd)

    unless status.success?
      raise "brew info failed: #{stderr.strip}"
    end

    data = JSON.parse(stdout)
    results = []

    (data['formulae'] || []).each do |f|
      results << { name: f['name'], type: 'brew', description: f['desc'] }
    end

    (data['casks'] || []).each do |c|
      results << { name: c['token'], type: 'cask', description: c['desc'] }
    end

    found_names = results.map { |r| r[:name] }
    missing = names - found_names
    raise "Package(s) not found: #{missing.join(', ')}" unless missing.empty?

    results
  end
end
