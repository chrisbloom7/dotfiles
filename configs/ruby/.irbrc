# `rails console` by default loads ~/.irbrc, but it will fail silently (i.e. not
# load it) if there are some errors in this file.

puts "Loading #{__FILE__}"

require "irb/completion"
require "rubygems"

def irbc_debug?
  case ENV["IRBC_DEBUG"]
  when nil, "", "false", 0, "0"
    false
  else
    true
  end
end

def irbc_log(message)
  puts message if irbc_debug?
end

IRB.conf[:AUTO_INDENT]  = true
IRB.conf[:HISTORY_FILE] = "#{ENV["HOME"]}/.irb-history"
IRB.conf[:SAVE_HISTORY] = 200

# Try loading Amazing Print or Awesome Print, if available
begin
  irbc_log "Attempting to load `amazing_print`"
  require "amazing_print"
  AmazingPrint.irb!
  irbc_log "Creating alias `pp` to `AmazingPrint.ap`"
  alias pp ap
  # irbc_log "Creating alias `puts` to `AmazingPrint.ap`"
  # alias puts ap
  irbc_log "Loaded AmazingPrint"
rescue LoadError
  irbc_log "Could not load amazing_print"
  begin
    irbc_log "Attempting to load `awesome_print`"
    require "awesome_print"
    AwesomePrint.irb!
    irbc_log "Creating alias `pp` to `AmazingPrint.ap`"
    alias :pp :ap
    # irbc_log "Creating alias `puts` to `AmazingPrint.ap`"
    # alias puts ap
    irbc_log "Loaded AwesomePrint"
  rescue LoadError
    irbc_log "Could not load awesome_print"
  end
end

# Use dotenv for loading environment variables, if available
begin
  irbc_log "Attempting to load `dotenv`"
  require "dotenv"
  Dotenv.load
  irbc_log "Loaded `dotenv`"
rescue LoadError
  irbc_log "Could not load `dotenv`"
rescue Errno::ENOENT
  irbc_log "Loaded `dotenv`, but no .env file found"
end

# Exit IRB with `q` or `quit` as well as `exit`
# alias q exit
irbc_log "Creating alias `quit` to `exit`"
alias quit exit

# Load project-specific .irbrc
begin
  irbc_log "Attempting to find local .irbc"
  irbc_log "Dir.pwd: #{Dir.pwd}"
  irbc_log "__dir__: #{__dir__}"
  irbc_log "File.dirname(__FILE__): #{File.dirname(__FILE__)}"

  if Dir.pwd != File.dirname(__FILE__) && Dir.pwd != __dir__
    irbc_log "Looking for project-specific .irbrc file in #{Dir.pwd}"
    local_irbrc = File.expand_path(".irbrc")
    if File.exist?(local_irbrc)
      load local_irbrc
      irbc_log "Loaded #{local_irbrc}"
    end
  end
rescue SyntaxError => e
  irbc_log "Could not parse project-specific .irbrc: #{e.message}"
end

# Companion method to Pry's built-in `disable_pry` method.
if defined?(Pry)
  irbc_log "Defining `enable_pry!` shortcut method to compliment `disable_pry`"
  def enable_pry!
    ENV['DISABLE_PRY'] = nil
  end
end

if defined?(ActiveRecord)
  irbc_log "Setting `ActiveRecord::Base.logger.level` to 1"
  ActiveRecord::Base.logger.level = 1
end
