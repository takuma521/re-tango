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
      if event.class == Line::Bot::Event::Unfollow
        user.destroy if user
        break
      end
      if user.blank?
        client.reply_message(event['replyToken'], user_registration_message)
        break
      end
      if user.words.blank?
        client.reply_message(event['replyToken'], null_word_message(user))
        break
      end
      if event.class == Line::Bot::Event::Postback
        data = event["postback"]["data"]
        phase = data.gsub(/phase=/, '').gsub(/&.+/, '')
        case phase
        when 'menu'
          word = user.words.shuffle.first
          client.reply_message(event['replyToken'], question(word))
          break
        when 'question'
          word_name = data.slice(/wordName=.+/).gsub(/wordName=/, '')
          word = user.words.find_by(name: word_name)
          client.reply_message(event['replyToken'], confirm(word))
          break
        when 'confirm'
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
      client.reply_message(event['replyToken'], menu(user))
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
            "type": "uri",
            "label": "単語登録",
            "uri": "https://#{Settings.domain}/users/#{user.uid}/words"
          },
          {
            "type": "postback",
            "label": "問題を出す",
            "data": "phase=menu"
          }
        ]
      }
    }
  end

  # メッセージ関連まとめる
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
            "label": "単語登録",
            "uri": "https://#{Settings.domain}/users/#{user.uid}/words"
          },
          {
            "type": "postback",
            "label": "問題を出す",
            "data": "phase=menu"
          }
        ]
      }
    }
  end

  def user_registration_message
    {
      "type": "template",
      "altText": "this is a buttons template",
      "template": {
        "type": "buttons",
        "text": "ユーザーを登録してください",
        "actions": [
          {
            "type": "uri",
            "label": "ユーザー登録",
            "uri": "https://#{Settings.domain}/users/auth/line"
          },
          {
            "type": "uri",
            "label": "単語登録",
            "uri": "https://#{Settings.domain}/users/auth/line"
          },
          {
            "type": "postback",
            "label": "問題を出す",
            "data": "phase=menu"
          }
        ]
      }
    }
  end
end
