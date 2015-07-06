require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require "sinatra/multi_route"
require 'json'

require 'trello'
require 'slack-poster'

ENV['environment'] = ENV['RACK_ENV'] || 'development'

require_relative 'lib/option_parser'
require_relative 'lib/helpers'
require_relative 'routes/slack.rb'

helpers do
  include SlackTello::RouteHelpers
end

before do
  halt(404) unless ENV['SLACK_TOKENS'].split(/,/).include?(params[:token])
end

get '/' do
  ""
end
