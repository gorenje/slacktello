post '/slack/commands' do
  case params[:command]
  when "/trello"
    username = params[:user_name]

    token,dev_key = (ENV["trello.keys.#{username}"] || "").split(/,/)
    if token.blank? || dev_key.blank?
      return "Trello keys not setup for *#{username}*"
    end

    Trello.configure do |cfg|
      cfg.member_token         = token
      cfg.developer_public_key = dev_key
    end

    # obtain the board either via the text or via a mapping or
    # via channel name.
    chnl   = params[:channel_name]
    crdtxt = params[:text]
    brd    = nil

    if crdtxt =~ /^[[:space:]]*board:(\w+|['"][^'"]+['"])[[:space:]]+(.+)$/
      brdname, crdtxt = $1, $2
      brdname = brdname.gsub(/["']/,'')
      brd = Trello::Board.all.select { |b| b.name == brdname }.first ||
              Trello::Board.all.select { |b| b.name =~ /#{brdname}/i }.first
      return "Unable to find board for boardname *#{brdname}*" if brd.nil?
    end

    if brd.nil?
      brdname = ENV["board.name.#{chnl}"] || chnl
      brd = Trello::Board.all.select { |b| b.name == brdname }.first ||
        Trello::Board.all.select { |b| b.name =~ /#{brdname} board/i }.first ||
        Trello::Board.all.select { |b| b.name =~ /#{brdname}/i }.first
      return "Unable to find board for channel *#{chnl}*" if brd.nil?
    end

    # obtain the list only via the ENV
    list = ENV["board.list.#{chnl}"] || "To Do"

    lst = brd.lists.select { |a| a.name == list }.first ||
            Trello::List.create(:name => "To Do", :board_id => brd.id)
    return "Unable to find or create list: *#{list}*" if lst.nil?

    return "No Text given, nothing done." if crdtxt.blank?

    begin
      card = Trello::Card.create(:name => crdtxt, :list_id => lst.id,
                                 :desc => "Created by SlackTello")

      if card
        unless ENV['SLACK_INCOMING_URL'].blank?
          options = {
            :icon_emoji => ':slacktello:',
            :username   => 'SlackTello',
            :channel    => "##{chnl}",
          }
          poster = Slack::Poster.new(ENV['SLACK_INCOMING_URL'], options)
          msg = ["<https://wooga.slack.com/messages/@#{username}|@#{username}>",
                 " just created *<#{card.url}|#{crdtxt}>* on the board ",
                 "*<#{brd.url}|#{brd.name}>*"].join
          poster.send_message(msg)
        end
        "Created new <#{card.url}|card> on *<#{brd.url}|#{brd.name}>*"
      else
        "Sorry, card could not be created."
      end
    rescue Exception => e
      "Sorry, Trello errored out: #{e.message}"
    end
  else
    "I dunno whatcha talking about Willis? "+
      "Command Unknown: #{params[:commamnd]}"
  end
end
