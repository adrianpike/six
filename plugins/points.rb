#
# Points plugin for CyBot.
# Adrian Pike <adrian.pike@gmail.com>
#

class Points < PluginBase
	ONLY_PEOPLE=false
	
	def initialize(*args)
		@brief_help = 'Keeps track of an arbitrary points value for people.'
		super(*args)
	end

	def cmd_p(irc,string)
		if string then
			ret = @points[string] ? @points[string] : "#{string} doesn't have any points yet!"
			irc.reply ret
		else
			irc.reply "You have to tell me what to check the points on!"
		end
	end

	def cmd_increment(irc,string)
		p "INCREMENT:#{string}"
		irc.reply "Unimplemented."
	end

	def cmd_decrement(irc,string)
		p "INCREMENT:#{string}"
		irc.reply "Unimplemented."
	end

	def parse(irc, username, val)
		case val
			when "++"
				@points[username] ? @points[username]+=1 : @points[username]=1
				irc.reply "Incremented."
			when "--"
				@points[username] ? @points[username]-=1 : @points[username]=-1
				irc.reply "Decremented."
		end
	end

	def hook_privmsg_chan(irc, msg)
		if ONLY_PEOPLE then
			nicks = irc.channel.users.collect{|k,u| Regexp.escape(u.nick) }
			regexp = Regexp.new /^\s*(#{nicks.join('|')})(\+\+|--)(.*)/
		else
			regexp = Regexp.new /^\s*(\w+)(\+\+|--)(.*)/
		end

		if msg =~ regexp
			parse(irc, "#{$1}", "#{$2}")
		end
	end
	
	
	# Load/save the phrases data
  # These seem to be called automatically at (un)load
  def load
    begin
      @points = YAML.load_file(file_name('points.yml'))
    rescue Exception => e
      @points = {}
    end
    @points = {} unless @points.is_a? Hash
  end
  def save
    begin
      open_file("points.yml", 'w') do |f|
        f.puts "# CyBot points plugin"
        YAML.dump(@points, f)
        f.puts
      end
      return true
    rescue Exception => e
      $log.puts e.message
      $log.puts e.backtrace.join("\n")
    end
    false
  end
end
