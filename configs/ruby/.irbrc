# `rails console` by default loads ~/.irbrc, but it will fail silently (i.e. not
# load it) if there are some errors in this file.

puts "Loading #{__FILE__}"

require "irb/completion"
require "rubygems"

IRB.conf[:AUTO_INDENT]  = true
IRB.conf[:HISTORY_FILE] = "#{ENV["HOME"]}/.irb-history"
IRB.conf[:SAVE_HISTORY] = 200

# Try loading Amazing Print or Awesome Print, if available
begin
  require "amazing_print"
  AmazingPrint.irb!
  alias pp ap
  alias puts ap
  puts "Loaded AmazingPrint"
rescue LoadError
  begin
    require "awesome_print"
    AwesomePrint.irb!
    alias pp ap
    alias puts ap
    puts "Loaded AwesomePrint"
  rescue LoadError
    nil
  end
end

# Use dotenv for loading environment variables, if available
begin
  require "dotenv"
  Dotenv.load
  puts "Loaded Dotenv"
rescue LoadError
  nil
rescue Errno::ENOENT
  puts "Loaded Dotenv, but no .env file found"
end

# Exit IRB with `q` or `quit` as well as `exit`
# alias q exit
alias quit exit

# Load project-specific .irbrc
begin
  # puts "\n\n\n"
  # puts "Dir.pwd: #{Dir.pwd}"
  # puts "__dir__: #{__dir__}"
  # puts "File.dirname(__FILE__): #{File.dirname(__FILE__)}"
  # puts "\n\n\n"

  if Dir.pwd != File.dirname(__FILE__) && Dir.pwd != __dir__
    puts "Looking for project-specific .irbrc file in #{Dir.pwd}"
    local_irbrc = File.expand_path(".irbrc")
    if File.exist?(local_irbrc)
      load local_irbrc
      puts "Loaded #{local_irbrc}"
    end
  end
rescue StandardError
  nil
end

# Companion method to Pry's built-in `disable_pry` method.
def enable_pry
  ENV['DISABLE_PRY'] = nil
end

ActiveRecord::Base.logger.level = 1 if defined?(ActiveRecord)
