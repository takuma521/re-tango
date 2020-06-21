class LinebotController < ApplicationController
  require 'line/bot'

  protect_from_forgery :except => [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = Rails.application.credentials[Rails.env.to_sym][:line][:message][:channel_secret]
      config.channel_token = Rails.application.credentials[Rails.env.to_sym][:line][:message][:channel_token]
    }
  end

  def callback
    message = LineMessage.new
    message.callback(request, client)
    head :ok
  end
end
