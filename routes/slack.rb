post '/slack/commands' do
  case params[:command]
  when "/trello"
    username = params[:user_name]

    token,dev_key = (ENV["trello.keys.#{username}"] || "").split(/,/)
    if token.blank? || dev_key.blank?
      return "Trello keys not setup for *#{username}*"
    end

    # obtain the board either via the text or via a mapping
    chnl   = params[:channel_name]
    crdtxt = params[:text]
    brd    = nil

    if crdtxt =~ /^[[:space:]]*board:(\w+|['"][^'"]+['"])[[:space:]]+(.+)$/
      brdname, crdtext = $1, $2
      brdname = brdname.gsub(/["']/,'')
      brd = Trello::Board.all.select { |b| b.name == brdname }.first
      brd = Trello::Board.all.
        select { |b| b.name =~ /#{brdname}/i }.first if brd.nil?
    end

    brd = Trello::Board.all.
      select { |b| b.name =~ /#{chnl}/i }.first if brd.nil?
    return "Unable to find board for channel *#{chnl}*" if brd.nil?

    # obtain the list only via the ENV
    list = ENV["board.list.#{chnl}"] || "To Do"

    Trello.configure do |cfg|
      cfg.member_token         = token
      cfg.developer_public_key = dev_key
    end

    lst = brd.lists.select { |a| a.name == list }.first
    lst = Trello::List.create(:name => "To Do", :board_id=> brd.id) if lst.nil?
    return "Unable to find or create list: *#{list}*" if lst.nil?

    return "No Text given, nothing done." if crdtxt.blank?
    card = Trello::Card.create(:name => params[:text], :list_id => lst.id,
                            :desc => "Created by SlackTello")

    card ? "New <#{r.url}|Card> created." : "Card not created"
  else
    "I dunno whatcha talking about Willis? "+
      "Command Unknown: #{params[:commamnd]}"
  end
end
