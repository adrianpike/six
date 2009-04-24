#
# Poker plugin for CyBot.
# Adrian Pike <adrian.pike@gmail.com>
#

require 'rubygems'
require 'ruby-poker'
require 'yaml'

class Poker < PluginBase

  def capture
    out = StringIO.new
    $stdout = out
	begin
	    yield
	rescue Exception=>e
	    $stdout = STDOUT
		p "THERE WAS AN ERROR IN CAPTURED OUTPUT #{e}"
	end
    $stdout = STDOUT
    return out
  end

	def initialize(*args)
		@brief_help = 'Lets us play a quick round of poker. Based upon adrianpike-ruby-poker.'
		@g = nil
		@users = []
		super(*args)
	end
	
	def cmd_new_hand(irc, string)
		if @g.is_a? TexasHoldEm then
			irc.reply "I've already got a game going!"
		else
			@g = TexasHoldEm.new
			irc.puts "We just started a game of Texas Hold 'Em - everybody yell *$in* who wants in!"
		end
	end

	def cmd_start(irc, string)
		if @users.size>1 then
			val = capture do
				@g.start 	
			end
			irc.puts val.string
			# Now let's tell everybody their hands
			@users.each {|u|
				irc.server.cmd('PRIVMSG', u, "Your poker hand is: #{@g.hand(u)}")
			}
		else
			irc.reply 'There\'s only one player in so far, that\'s pretty stupid to play against yourself.'
		end
	end

	def cmd_abort(irc, string)
		@g=nil
		irc.reply "OK, I cancelled that game."
	end
	
	def cmd_in(irc, string)
		if @g then
			@g.new_player(irc.from.to_s)
			@users << irc.from.to_s
			irc.reply "you're in!"
		else
			irc.reply "There's not any current game being set up, why not start one?"
		end
	end

	def cmd_bet(irc, string)
		if @g and @g.started? then
			val = capture do
				@g.bet(irc.from.to_s, string.to_i)
			end
			irc.puts val.string
		else
			irc.reply "There's not any current game that's started."
		end
	end

	def cmd_fold(irc, string)
		if @g and @g.started? then	
			val = capture do
				@g.fold(irc.from.to_s)
			end
			irc.puts val.string
		else
			irc.reply "There's not any current game that's started."
		end
	end
end