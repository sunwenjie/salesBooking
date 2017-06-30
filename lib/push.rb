SERVER = 'pop.i-click.com'
USERNAME = 'bj_dev@i-click.com'
PW = 'Xmo_dev2012'
require 'net/imap'

# Extend support for idle command. See online.
# http://www.ruby-forum.com/topic/50828
# https://gist.github.com/jem/2783772
# but that was wrong. see /opt/ruby-1.9.1-p243/lib/net/imap.rb.
class Net::IMAP
  def idle
    cmd = "IDLE"
    synchronize do
      @idle_tag = generate_tag
      put_string(@idle_tag + " " + cmd)
      put_string(CRLF)
    end
  end

  def say_done
    cmd = "DONE"
    synchronize do
      put_string(cmd)
      put_string(CRLF)
    end
  end

  def await_done_confirmation
    synchronize do
      get_tagged_response(@idle_tag, nil)
      puts 'just got confirmation'
    end
  end


end


class Remailer
  attr_reader :imap

  public
  def initialize
    @imap = nil
    @mailer = nil
    start_imap
  end

  def tidy
    stop_imap
  end

  def print_pust
       envelope = @imap.fetch(-1, "ENVELOPE")[0].attr["ENVELOPE"]
       body = @imap.fetch(-1, "BODY[TEXT]")[0].attr["BODY[TEXT]"]
       puts "From: #{envelope.from[0].name}\t Subject: #{envelope.subject}\n Text: #{body}"
       if body=~/^yes/
         p "true"
       else
         p "false"
       end 
  end

  def bounce_idle
    # Bounces the idle command.
    @imap.say_done
    @imap.await_done_confirmation
    # Do a manual check, just in case things aren't working properly.
    @imap.idle
  end

  private
  def start_imap
    @imap = Net::IMAP.new('pop.i-click.com')
    @imap.login USERNAME, PW
    @imap.select 'INBOX'

    # Add handler.
    @imap.add_response_handler do |resp|
      if resp.kind_of?(Net::IMAP::UntaggedResponse) and resp.name == "EXISTS"
        @imap.say_done
        Thread.new do
          @imap.await_done_confirmation
          print_pust
          @imap.idle
        end
      end
    end
    @imap.idle
  end

  def stop_imap
    @imap.done
  end

end

begin
  Net::IMAP.debug = true
  r = Remailer.new
  loop do
    puts 'bouncing...'
    r.bounce_idle
    sleep 15*60
    #15分钟无操作保持联系
  end
ensure
  r.tidy
end