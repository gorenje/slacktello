route :get, :post, '/slack/commands' do
  case params[:command]
  when '/trello'
    opts = SlackTello::OptionParser.new.parse(params[:text])
    return opts.help if opts.is_in_error?
    return all_trello_users if opts.show_users?

    result = configure_trello(params[:user_name])
    return result unless result.nil?

    chnl = params[:channel_name]

    if opts.which_board
      brd = find_trell_board_for_channel(opts.board, chnl)
      if brd
        "This would go into the Board: *<#{brd.url}|#{brd.name}>*"
      else
        "No board for Channel: #{chnl} & CmdLine: #{params[:text]}"
      end
    else
      return "No Text given, nothing done." if opts.text.blank?

      brd = find_trell_board_for_channel(opts.board, chnl)
      return "No board found for Channel #{chnl}" if brd.nil?

      list = opts.list || ENV["board.list.#{chnl}"] || "To Do"
      lst  = find_or_create_trello_list_in_board(brd, list)

      begin
        card = Trello::Card.create(:name    => opts.text,
                                   :list_id => lst.id,
                                   :desc    => "Created by SlackTello")
        if card
          post_back_to_slack(card, brd, chnl)
          "Created new <#{card.url}|card> on *<#{brd.url}|#{brd.name}>*"
        else
          "Sorry, card could not be created."
        end
      rescue Exception => e
        "Sorry, Trello errored out: #{e.message}"
      end
    end
  else
    "I dunno whatcha talking about Willis? "+
      "Command Unknown: #{params[:command]}"
  end
end
