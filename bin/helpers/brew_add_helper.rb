# brew_add_helper.rb
# Adds packages to a Brewfile using brew info JSON from STDIN.
# Called by bin/brew_add — not executable.
#
# Usage:
#   brew info --json=v2 <pkg>... | ruby helpers/brew_add_helper.rb <brewfile_path>
#
# Output (STDOUT): JSON array of result objects:
#   [{ "name": "git", "type": "brew", "status": "added"|"uncommented"|"already_present" }, ...]
#
# Exits non-zero on failure.

require 'json'
require_relative 'brewfile'

brewfile_path = ARGV[0] or abort 'Usage: brew_add_helper.rb <brewfile_path>'
abort "Brewfile not found: #{brewfile_path}" unless File.exist?(brewfile_path)

data = JSON.parse($stdin.read)

packages = []
(data['formulae'] || []).each { |f| packages << { name: f['name'],  type: 'brew', description: f['desc'] } }
(data['casks']    || []).each { |c| packages << { name: c['token'], type: 'cask', description: c['desc'] } }

abort 'No packages found in brew info output' if packages.empty?

bf      = Brewfile.new(brewfile_path)
results = []

packages.each do |pkg|
  status = bf.add(name: pkg[:name], type: pkg[:type], description: pkg[:description])
  results << { 'name' => pkg[:name], 'type' => pkg[:type], 'status' => status.to_s }
end

bf.write(brewfile_path)
puts JSON.generate(results)
