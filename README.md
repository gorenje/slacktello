SlackTello
---

Bridge between Slack and Trello to create cards from slack commands.

Configuration
---

Designed to be deployed to heroku but just needs the following setup:

    SLACK_TOKENS=token,token2,...

comma list of slack tokens generated when creating a new slack command.

Now it gets complicated! For each slack user, need to create a variable
containing their trello keys:

    trello.keys.<slack user name>=<token>,<dev key>

Each trello user can obtain their key and token from [trello](http://www.trello.org/help.html). Their slack user name can be found out by trying out the
command '/trello' in slack - it will echo back with your slack username.

Why do this?

Because cards are created in a users name, so they get the correct creator.

Board Name
---

So which board do cards go to?

SlackTello tries to be clever about this and take the channel name from
which the command was run, e.g. from the tracking channel:

    #tracking> /trello hello world

SlackTello will look for a board with the name:

    tracking
    /tracking board/i ## regular expression
    /tracking/i ## regular expression

There are a number of ways of overriding this, one by setting the
environment variable:

    board.name.tracking=Some Board Name

which would make slacktello, instead of the board names above, look for:

    Some Board Name
    /Some Board Name board/i ## regular expression
    /Some Board Name/i ## regular expression

One other way of overriding this is to use the board argument:

    #tracking> /trello board:"Some Board Name" some card text

this would make slacktello look for the board names:

    Some Board Name
    /Some Board Name/i ## regular expression

If no board is found, then slacktello gives up.

List Name
---

Cards are created in the To Do list by default. If the list does not exist,
it's created. The list name can be overridden by setting the following:

    board.list.<channel name>=Some List Name

Note: this only works with the channel name, nothing else.
