SlackTello
===

Heroku bridge between Slack and Trello to create cards from slack commands.

Configuration
===

Designed to be deployed to heroku and just needs the following setup:

    SLACK_TOKENS=token,token2,...

comma list of slack tokens generated when [creating a new slack command](https://slack.zendesk.com/hc/en-us/articles/201259356-Using-slash-commands).

Now it gets complicated! For each slack user, need to create a variable
containing their trello keys:

    trello.keys.<slack user name>=<token>,<dev key>

Each trello user can obtain their key and token from [trello](http://www.trello.org/help.html). Their slack user name can be found out by trying out the
command '/trello' in slack - it will echo back with your slack username (if
the [slack command](https://slack.zendesk.com/hc/en-us/articles/201259356-Using-slash-commands) was already created).

In the end, you'll need a URL that looks like this:

    https://trello.com/1/authorize?key=substitute_with_your_application_key&name=My+Application&expiration=never&response_type=token&scope=read,write

Important here is the ```scope``` value of ```read,write``` otherwise you
won't be able to create cards but only read them.

Why do this?

Because cards are created in a users name, so cards are created with the
correct creator.

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

Post Back
---

Normally the output of trello command is echo'ed just to the user who created
the card and not posted in the channel from which they created the card.

You can change this behaviour and get a message posted in the channel by
adding the following environment variable:

    SLACK_INCOMING_URL=<slack url>

You obtain the url [from slack](https://api.slack.com/incoming-webhooks). Note this url is bound to a channel
but can be used for any channel and slacktello will override the default
channel with the one from which the card was created.

Heroku
===

Host this on heroku is a matter of creating an [application](https://www.heroku.com/features) at Heroku and
pushing this code to that application. You'll have a heroku URL to access
the application and you can use that as endpoint for your slack command, e.g.:

    https://slacktello.herokuapp.com/slack/commands

Important is to use the ```slack/commands``` path on the URL.

[![Deploy To Heroku](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy?template=https://github.com/wooga/slacktello)

Thanks
===

Thanks to the developers of the [ruby-trello](https://rubygems.org/gems/ruby-trello) gem and to the developers of [slack-poster](https://rubygems.org/gems/slack-poster) - made developing slacktello too easy!

License
===

Released under the GPLv2.

See https://www.gnu.org/licenses/gpl-2.0 for details.

Contributing to SlackTello
===

* fork the project
* start a feature branch
* make sure to add tests
* please try not to mess with the Rakefile, version, or history
