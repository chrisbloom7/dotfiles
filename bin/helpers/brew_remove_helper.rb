# brew_remove_helper.rb
# Removes packages from one or more Brewfiles using brew info JSON from STDIN.
# Called by bin/brew_remove — not executable.
#
# Usage:
#   brew info --json=v2 <pkg>... | ruby helpers/brew_remove_helper.rb <brewfile_path> [<brewfile_path> ...]
#
# Output (STDOUT): JSON array of result objects:
#   [{ "name": "git", "type": "brew", "brewfile": "Brewfile.common", "status": "removed"|"not_found" }, ...]
#
# Exits non-zero on failure.

require 'json'
require_relative 'brewfile'

brewfile_paths = ARGV.dup
abort 'Usage: brew_remove_helper.rb <brewfile_path> [<brewfile_path> ...]' if brewfile_paths.empty?
brewfile_paths.each { |p| abort "Brewfile not found: #{p}" unless File.exist?(p) }

data = JSON.parse($stdin.read)

packages = []
(data['formulae'] || []).each { |f| packages << { name: f['name'],  type: 'brew' } }
(data['casks']    || []).each { |c| packages << { name: c['token'], type: 'cask' } }

abort 'No packages found in brew info output' if packages.empty?

results = []

brewfile_paths.each do |path|
  bf       = Brewfile.new(path)
  modified = false

  packages.each do |pkg|
    status = bf.remove(name: pkg[:name], type: pkg[:type])
    results << { 'name' => pkg[:name], 'type' => pkg[:type], 'brewfile' => File.basename(path), 'status' => status.to_s }
    modified = true if status == :removed
  end

  bf.write(path) if modified
end

puts JSON.generate(results)
