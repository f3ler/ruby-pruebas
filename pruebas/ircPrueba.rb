require 'socket'

# License :
  # IRCSocket class to allow the easy creation of IRC bots in Ruby.
  # Copyright (C) 2004  Olathe
  #
  # This library is free software; you can redistribute it and/or
  # modify it under the terms of the GNU Library General Public
  # License as published by the Free Software Foundation; either
  # version 2 of the License, or (at your option) any later version.
  #
  # This library is distributed in the hope that it will be useful,
  # but WITHOUT ANY WARRANTY; without even the implied warranty of
  # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  # Library General Public License for more details.
  #
  # You should have received a copy of the GNU Library General Public
  # License along with this library; if not, write to the
  # Free Software Foundation, Inc., 59 Temple Place - Suite 330,
  # Boston, MA  02111-1307, USA.

# TO DO :
  # Make the methods like msg use r_msg for display, so that if someone overrides it, it changes the look of received AND sent msgs.
  # Expand method_missing to add a colon to the front of the last argument if it is multiworded.

# This code is nowhere near complete.  If you build on it, newer versions won't work with your code because I don't care about backward compatibility yet.

# Events: msg, act, notice, ctcp, ctcpreply, mode, join, part, kick, quit, nick, login, ping, raw, miscellany
# Action methods: msg, act, notice, ctcp, ctcpreply, mode, join, part, quit, nick, user, tx (or raw or quote)

# handle(:event, argument_1, argument_2, ...): Calls _event and r_event properly.
# _event(argument_1, argument_2, ...): What to do when the event happens.  If this returns true, r_event isn't used and the event is hidden.
# r_event(argument_1, argument_2, ...): How to report the event to the console.
# report(line): Reports events to the console.

class IRCSocket < TCPSocket
  private
    @me; @nicknames; @registered; @reportmode; @heldreports

  public
    attr_reader :me, :registered
    
    def initialize(address, port, username, realname)
      @me = ''
      @nicknames = ['IRCSocket', 'IRCSocket2', 'IRCSocket3'] if (@nicknames.nil?) 
      @registered = false
      @reportmode = :passthrough
      @heldreports = []
      super(address, port)
      report "test"
      user username, '0.0.0.0', address, realname
      nick @nicknames[0]
    end

    def tx(line)
      puts line
      report "bot:  #{line}"
    end
    
    def rx
      line = gets.chomp
      case line 
        when /^:((.+?)(?:!.+?)?) PRIVMSG (\S+?) :?\001ACTION (.+?)\001$/i
          handle :act, $1, $2, $3, $4
        when /^:((.+?)(?:!.+?)?) PRIVMSG (\S+?) :?\001(.+?)\001$/i
          handle :ctcp, $1, $2, $3, $4
        when /^:((.+?)(?:!.+?)?) PRIVMSG (\S+?) :?(.+?)$/i
          handle :msg, $1, $2, $3, $4
        when /^:((.+?)(?:!.+?)?) NOTICE (\S+?) :?\001(.+?)\001$/i
          handle :ctcpreply, $1, $2, $3, $4
        when /^:((.+?)(?:!.+?)?) NOTICE (\S+?) :?(.+?)$/i
          handle :notice, $1, $2, $3, $4
	when /^:((.+?)(?:!.+?)?) MODE (\S+?) :?(\S+?)(?: (.+?))?$/i
          handle :mode, $1, $2, $3, $4, $5
        when /^:((.+?)(?:!.+?)?) JOIN :?(\S+?)$/i
          handle :join, $1, $2, $3
        when /^:((.+?)(?:!.+?)?) PART (\S+?)(?: :?(\S+?)?)?$/i
          handle :part, $1, $2, $3, $4
        when /^:((.+?)(?:!.+?)?) KICK (\S+?) (\S+?) :?(.+?)$/i
          handle :kick, $1, $2, $3, $4, $5
        when /^:((.+?)(?:!.+?)?) QUIT :?(.+?)$/i
          handle :quit, $1, $2, $3
        when /^:((.+?)(?:!.+?)?) NICK :?(\S+?)$/i
	  handle :nick, $1, $2, $3
        when /^PING :?(.+?)$/i
          handle :ping, $1
        when /^:((.+?)(?:!.+?)?) (\d{3})\s+(\S+?) (.+?)$/i
	  handle :raw, $1, $2, $3.to_i, $4, $5
	else
          handle :miscellany, line
      end
    end

  private

    def r_msg(fullactor, actor, target, text)
	report "{#{target}} <#{actor}> #{text}"
    end
    
    def r_act(fullactor, actor, target, text)
      report "{#{target}} * #{actor} #{text}"
    end

    def r_notice(fullactor, actor, target, text)
	report "{#{target}} -#{actor}- #{text}"
    end
    
    def r_ctcp(fullactor, actor, target, text)
      report "{#{target}} [#{actor} #{text}]"
    end
    
    def r_ctcpreply(fullactor, actor, target, text)
      report "{#{target}} [Reply: #{actor} #{text}]"
    end
    
    def r_mode(fullactor, actor, target, modes, objects)
      report "{#{target}} #{actor} sets mode #{modes} #{objects}"
    end
    
    def r_join(fullactor, actor, target)
      report "{#{target}} #{actor} joins"
    end
    
    def r_part(fullactor, actor, target, text)
      report "{#{target}} #{actor} parts (#{text})"
    end
    
    def r_kick(fullactor, actor, target, object, text)
      report "{#{target}} #{actor} kicked #{object} (#{text})"
    end
    
    def r_quit(fullactor, actor, text)
      report "#{actor} quit (#{text})"
    end
    
    def _nick(fullactor, actor, nickname)
      case actor
        when /#{@me}/i
	  @me = nickname
      end
    end
    
    def r_nick(fullactor, actor, nickname)
      report "#{actor} changed nick to #{nickname}"
    end

    def _ping(text)
      puts "PONG :#{text}"
    end
    
    def _raw(fullactor, actor, numeric, target, text)
      case numeric
        when 001
	  report "Raw #{numeric.to_s} from #{fullactor}: #{text}"
	  text =~ /(\S+)!\S+$/
	  @me = $1
	  handle :login
	# Channel URL
	when 328
	  text =~ /^(\S+) :?(.+)$/
	  report "{#{$1}} URL is #{$2}"
	# Channel topic
	when 332
	  text =~ /^(\S+) :?(.+)$/
	  report "{#{$1}} Topic is: #{$2}"
	# Channel topic setter
	when 333
	  text =~ /^(\S+) (\S+) (\d+)$/
	  report "{#{$1}} Topic set by #{$2} on #{Time.at($3.to_i).asctime}"
	# Names line
	when 353
	  text =~ /^(@|\*|=) (\S+) :?(.+)$/
	  channeltype = {'@' => 'Secret', '*' => 'Private', '=' => 'Normal'}[$1]
	  report "{#{$2}} #{channeltype} channel nickname list: #{$3}"
	# End of names
	when 366
	  text =~ /^(\S+)/
	  report "{#{$1}} Nickname list complete"
	# MOTD line
	when 372
	  text =~ /^:?(.+)$/
	  report "*MOTD* #{$1}"
	# Beginning of MOTD
	when 375
	  text =~ /^:?(.+)$/
	  report "*MOTD* #{$1}"
	# End of MOTD
	when 376
          report "*MOTD* End of MOTD"
	# Nickname change failed: already in use
	when 433
	  text =~ /^(\S+)/
	  report "Nickname #{$1} is already in use."
	  if (!@registered)
	    begin
	      nextnick = @nicknames[(0...@nicknames.length).find { |i| @nicknames[i] == $1 } + 1]
	      if (nextnick != nil)
	        nick nextnick
	      else
	        report '*** All nicknames in use. ***'
	        quit 'All nicknames in use.'
	      end
	    rescue
	      report '*** Nickname selection error. ***'
	      quit 'Nickname selection error.'
	    end
	  end
	else
          report "Unknown raw #{numeric.to_s} from #{fullactor}: #{text}"
      end
    end
    
    def _login
      @registered = true
      mode @me, 'i'
    end
    
    def r_login
      report "*** Logged in as #{@me}. ***"
    end
    
    def r_miscellany(line)
      report "serv: #{line}"
    end

  public
    def msg(target, text, silent=false)
      report "{#{target}} <#{@me}> #{text}" if (!silent)
      puts "PRIVMSG #{target} :#{text}"
    end
    
    def act(target, text, silent=false)
      report "{#{target}} * #{@me} #{text}" if (!silent)
      ctcp target, "ACTION #{text}", true
    end
    
    def notice(target, text, silent=false)
      report "{#{target}} -#{@me}- #{text}" if (!silent)
      puts "NOTICE #{target} :#{text}"
    end
    
    def ctcp(target, text, silent=false)
      report "{#{target}}  [#{@me} #{text}]" if (!silent)
      msg target, "\001#{text}\001", true
    end
    
    def ctcpreply(target, text, silent=false)
      report "{#{target}} [Reply: #{@me} #{text}]" if (!silent)
      notice target, "\001#{text}\001", true
    end

    def mode(target, modes='', objects='')
      message = "MODE #{target}"; message += " #{modes}" if ((modes != '') and (modes != nil)); message += " #{objects}" if ((objects != '') and (objects != nil))
      raw message
    end

    def join(target)
      raw "JOIN #{target}"
    end

    def part(target, text='')
      request = "PART #{target}"; message += " :#{text}" if ((text != '') and (text != nil))
      raw request
    end
    
    def quit(text='')
      request = "QUIT"; message += " :#{text}" if ((text != '') and (text != nil))
      raw request
    end

    def nick(nick)
      raw "NICK :#{nick}"
    end
    
    def user(username='IRCSocket', myaddress='0.0.0.0', address='server', realname='Ruby IRCSocket')
      raw "USER #{username} #{myaddress} #{address} :#{realname}"
    end
    
    alias_method :raw, :tx
    alias_method :quote, :tx

    # If a method is used that isn't coded, send it as a command to the server.
      # For example, bot.privmsg channel, ':test' will send "privmsg #{channel} :test" to the server.
    # If an event-handling method (_event or r_event) is used that isn't coded, ignore it.
    def method_missing(symbol, *arguments)
      if (symbol.to_s !~ /^r?_/)
        raw "#{symbol} #{arguments.join(' ')}"
      end
    end

  private
    # handle() calls _event() to handle an event.  If _event() doesn't return true (to silence the report), r_event() is called to report the event to the console.
    # handle() also ensures that report() displays messages to the console in the order they occurred.
    def handle(event, *arguments)
      @reportmode = :capture
      if (__send__("_#{event}", *arguments) != true)
        @reportmode = :passthrough
        __send__("r_#{event}", *arguments)
      end
      @reportmode = :release
      report
      @reportmode = :passthrough
    end
    
    # If you want to change the look or destination of the reports to the console, override reporter(), not report().
    def reporter(line)
      $stdout.puts "(#{Time.now.strftime('%H:%M.%S')}) #{line}"
    end
    
  public
    
    # report() displays messages to the console in the order they occurred.
    def report(*lines)
      if (@reportmode == :capture)
        @heldreports.push(lines).flatten!
      else
        @heldreports.delete_if { |line| reporter line; true } if (@reportmode == :release)
	lines.each { |line| reporter line } if (lines != nil)
      end
    end
end
