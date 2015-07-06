module SlackTello
  module RouteHelpers
    def trello_key_for(username)
      ENV["trello.keys.#{username}"] || ENV["trello_keys_#{username}"] || ""
    end

    def all_trello_users
      users = ENV.keys.
        select { |a| a =~ /trello[._]keys[._]/ }.
        map { |k| k.gsub(/trello[._]keys[._]/,'') }

      msg = users.include?(params[:user_name]) ? " " : " *not* "

      "Your username *#{params[:user_name]}* has#{msg}been configured. "+
        "Following users have:\n" +
        users.map { |a| "*<https://wooga.slack.com/messages/@#{a}|@#{a}>*"}.
        join(",") + "\n"
    end

    def configure_trello(username)
      token,dev_key = trello_key_for(username).split(/,/)

      if token.blank? || dev_key.blank?
        return "Trello keys not setup for *#{username}*"
      end

      Trello.configure do |cfg|
        cfg.member_token         = token
        cfg.developer_public_key = dev_key
      end
      nil
    end

    def find_trell_board_for_channel(brdname, chnl)
      [brdname,
       ENV["board.name.#{brdname}"],
       ENV["board.name.#{chnl}"],
       chnl].compact.each do |name|
        brd =
          Trello::Board.all.select { |b| b.name == name }.first ||
          Trello::Board.all.select {|b| b.name =~ /#{brdname} board/i }.first ||
          Trello::Board.all.select {|b| b.name =~ /#{name}/i }.first ||
          nil
        return brd if brd
      end
      nil
    end

    def find_or_create_trello_list_in_board(brd, list)
      brd.lists.select { |a| a.name == list }.first ||
        Trello::List.create(:name => list, :board_id => brd.id)
    end

    def post_back_to_slack(card, brd, chnl)
      unless ENV['SLACK_INCOMING_URL'].blank?
        username = params[:user_name]
        options = {
          :icon_emoji => ':slacktello:',
          :username   => 'SlackTello',
          :channel    => "##{chnl}",
        }
        poster = Slack::Poster.new(ENV['SLACK_INCOMING_URL'], options)
        msg = ["<https://wooga.slack.com/messages/@#{username}|@#{username}>",
               " just created *<#{card.url}|#{card.name}>* on the board ",
               "*<#{brd.url}|#{brd.name}>*"].join
        poster.send_message(msg)
      end
    end
  end
end
