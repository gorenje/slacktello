require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'json'

require 'trello'

ENV['environment'] = ENV['RACK_ENV'] || 'development'

require_relative 'routes/slack.rb'

before do
  halt(404) unless ENV['SLACK_TOKENS'].split(/,/).include?(params[:token])
end

get '/' do
  ""
end
