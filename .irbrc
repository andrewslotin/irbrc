require 'irb/completion'
require 'irb/ext/save-history'

%w{rubygems wirble pp hirb}.each do |gem|
  begin
    require gem
  rescue LoadError => err
    warn "Gem not loaded: #{err}"
  end
end

IRB.conf[:SAVE_HISTORY] = 100
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb-save-history" 
IRB.conf[:PROMPT_MODE]  = :SIMPLE

# Just for Rails...
if rails_env = ENV['RAILS_ENV']
  rails_root = File.basename(Dir.pwd)
  IRB.conf[:PROMPT] ||= {}
  IRB.conf[:PROMPT][:RAILS] = {
    :PROMPT_I => "#{rails_root}@#{ENV['RAILS_ENV']}> ",
    :PROMPT_S => "#{rails_root}@#{ENV['RAILS_ENV']}* ",
    :PROMPT_C => "#{rails_root}@#{ENV['RAILS_ENV']}? ",
    :RETURN   => "=> %s\n" 
  }
  IRB.conf[:PROMPT_MODE] = :RAILS

  # Called after the irb session is initialized and Rails has
  # been loaded (props: Mike Clark).
  IRB.conf[:IRB_RC] = Proc.new do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Base.instance_eval { alias :[] :find }
  end
end

if Object.const_defined?('Wirble')
  Wirble.init
  Wirble.colorize
end

if Object.const_defined?('Hirb')
  Hirb.enable
  extend Hirb::Console
end

def clear
  system 'clear'
  return ENV['RAILS_ENV'] || 'IRB'
end
