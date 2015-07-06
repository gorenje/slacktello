require_relative "../test_helper"

class OptionParserTest < Minitest::Test
  context "handle command line" do
    should "have -l option in short and long form" do
      ["-l 'list name' card text",
       "--list 'list name' card text",
      ].each do |cmdline|
        failure_msg = "Failed for #{cmdline}"
        opts = SlackTello::OptionParser.new.parse(cmdline)
        assert !opts.is_in_error?, failure_msg
        assert_equal 'list name', opts.list, failure_msg
        assert_equal 'card text', opts.text, failure_msg
        assert !opts.which_board
      end

      ["-l 'list' card text",
       "--list 'list' card text",
       '--list "list" card text',
      ].each do |cmdline|
        failure_msg = "Does not ignore quotes for #{cmdline}"
        opts = SlackTello::OptionParser.new.parse(cmdline)
        assert !opts.is_in_error?, failure_msg
        assert_equal 'list', opts.list, failure_msg
        assert !opts.which_board
      end
    end

    should "have -b option in short and long form" do
      ["-b 'board name' card text",
       "--board 'board name' card text",
      ].each do |cmdline|
        failure_msg = "Failed for #{cmdline}"
        opts = SlackTello::OptionParser.new.parse(cmdline)
        assert !opts.is_in_error?, failure_msg
        assert_equal 'board name', opts.board, failure_msg
        assert_equal 'card text', opts.text, failure_msg
        assert !opts.which_board
      end
    end

    should "have -h option in short and long form and it's in error" do
      ["-h 'board name' card text",
       "--help 'board name' card text",
       "--help -b 'board name' -l list card text"
      ].each do |cmdline|
        failure_msg = "Failed for #{cmdline}"
        opts = SlackTello::OptionParser.new.parse(cmdline)
        assert opts.is_in_error?, failure_msg
        assert !opts.which_board
      end
    end

    should "have show users option" do
      ["-b 'board name' card text -u",
       "-l 'list' card text --users",
      ].each do |cmdline|
        failure_msg = "Failed for #{cmdline}"
        opts = SlackTello::OptionParser.new.parse(cmdline)
        assert !opts.is_in_error?, failure_msg
        assert opts.show_users?, failure_msg
        assert !opts.which_board
      end
    end

    should "which board in combination with board name" do
      opts = SlackTello::OptionParser.new.parse("-b 'board name' -w")
      assert !opts.is_in_error?
      assert opts.which_board
      assert !opts.show_users?
    end
  end
end
