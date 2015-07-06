require 'optparse'
require 'shellwords'

module SlackTello
  class OptionParser
    attr_reader :board, :which_board, :opts, :error_message, :text, :list

    def initialize
      @which_board   = false
      @error_message = nil
      @board         = nil
      @text          = nil
      @list          = nil
    end

    def parse(str)
      @opts = ::OptionParser.new do |opts|
        opts.banner = "Usage: /trello [options]"
        opts.on("-b", "--board BOARD", "Board to post card into") do |brd|
          @board = brd
        end
        opts.on("-l", "--list LIST", "List in Board to post card into") do |lst|
          @list = lst
        end
        opts.on("-w", "--which", "Show the board to which cards are posted from this channel") do
          @which_board = true
        end
        opts.on("-h", "--help", "Show this help") do
          @error_message = "Help:"
        end
      end

      begin
        @text = @opts.parse!(Shellwords.shellwords(str)).join(" ")
      rescue Exception => e
        @error_message = e.message
      end

      self
    end

    def is_in_error?
      !@error_message.nil?
    end

    def help
      "*#{ @error_message}*\n#{@opts.help}"
    end
  end
end
