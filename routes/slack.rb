post '/slack/commands' do
  case params[:command]
  when "/trello"
    username = params[:user_name]

    token,dev_key = (ENV["trello.keys.#{username}"] || "").split(/,/)
    if token.blank? || dev_key.blank?
      return "Trello keys not setup for *#{username}*"
    end

    board,list = (ENV["trello.dest.#{username}"] || "").split(/,/)
    return "Trello _board_ not setup for *#{username}*" if board.blank?
    list ||= "To Do"

    Trello.configure do |cfg|
      cfg.member_token         = token
      cfg.developer_public_key = dev_key
    end

    brd = Trello::Board.all.select { |b| b.name == board }.first
    return "Unable to find board: *#{board}*" if brd.nil?

    lst = brd.lists.select { |a| a.name == list }.first
    return "Unable to find list: *#{list}*" if lst.nil?

    return "No Text given, nothing done." if params[:text].blank?
    r = Trello::Card.create(:name => params[:text], :list_id => lst.id,
                            :desc => "Created by SlackTello")

    if r
      "New <#{r.url}|Card> created."
    else
      "Card not created"
    end
  else
    "I dunno whatcha talking about Willis? "+
      "Command Unknown: #{params[:commamnd]}"
  end
end
