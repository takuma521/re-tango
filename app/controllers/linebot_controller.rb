class LinebotController < ApplicationController
  require 'line/bot'

  protect_from_forgery :except => [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = Rails.application.credentials.line[:message][:channel_secret]
      config.channel_token = Rails.application.credentials.line[:message][:channel_token]
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)

    events.each { |event|
      user = User.find_by(uid: event["source"]["userId"])
      if user.words.empty?
        client.reply_message(event['replyToken'], null_word_message(user))
        break
      end
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          client.reply_message(event['replyToken'], menu(user))
        end
      when Line::Bot::Event::Postback
        data = event["postback"]["data"]
        phase = data.gsub(/phase=/, '').gsub(/&.+/, '')
        case phase
        when 'menu'
          word = user.words.shuffle.first
          client.reply_message(event['replyToken'], question(word))
        when 'question'
          word_name = data.slice(/wordName=.+/).gsub(/wordName=/, '')
          word = user.words.find_by(name: word_name)
          client.reply_message(event['replyToken'], confirm(word))
        when 'confirm'
          client.reply_message(event['replyToken'], menu(user))
          word_name = data.slice(/wordName=.+&/).gsub(/wordName=/, '').gsub(/&/, '')
          word = user.words.find_by(name: word_name)
          # TODO: transaction rescue
          is_correct = data.slice(/isCorrect=.+/).gsub(/isCorrect=/, '')
          ActiveRecord::Base.transaction do
            word.question_count += 1
            if is_correct == 'true'
              word.correct_answer_count += 1
            end
            word.save!
          end
        end
      end
    }
    head :ok
  end

  private

  def menu(user)
    {
      "type": "template",
      "altText": "this is a buttons template",
      "template": {
        "type": "buttons",
        "text": "メニュー",
        "actions": [
          {
            "type": "postback",
            "label": "次の問題",
            "data": "phase=menu"
          },
          {
            "type": "uri",
            "label": "単語の登録",
            # TODO: develop, prodction環境ごとのurlに対応する
            "uri": "https://6ee66fd4.ngrok.io/users/#{user.uid}/words"
          }
        ]
      }
    }
  end

  def question(word)
    {
      "type": "template",
      "altText": "this is a buttons template",
      "template": {
        "type": "buttons",
        "text": word.name,
        "actions": [
          {
            "type": "postback",
            "label": "答えを見る",
            "data": "phase=question&wordName=#{word.name}"
          }
        ]
      }
    }
  end

  def confirm(word)
    {
      "type": "template",
      "altText": "this is a buttons template",
      "template": {
        "type": "buttons",
        "text": word.translation,
        "actions": [
          {
            "type": "postback",
            "label": "正解した",
            "data": "phase=confirm&wordName=#{word.name}&isCorrect=true"
          },
          {
            "type": "postback",
            "label": "間違えた",
            "data": "phase=confirm&wordName=#{word.name}&isCorrect=false"
          }
        ]
      }
    }
  end

  def null_word_message(user)
    {
      "type": "template",
      "altText": "this is a buttons template",
      "template": {
        "type": "buttons",
        "text": "単語を登録してください",
        "actions": [
          {
            "type": "uri",
            "label": "単語の登録",
            # TODO: develop, prodction環境ごとのurlに対応する
            "uri": "https://6ee66fd4.ngrok.io/users/#{user.uid}/words"
          },
          {
            "type": "postback",
            "label": "次の問題",
            "data": "phase=menu"
          }
        ]
      }
    }
  end
end
