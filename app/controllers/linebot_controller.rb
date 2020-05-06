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
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          client.reply_message(event['replyToken'], menu(user))
        end
      when Line::Bot::Event::Postback
        query = event["postback"]["data"]
        phase = query.gsub(/phase=/, '').gsub(/&.+/, '')
        case phase
        when 'menu'
          # TODO: どのbookから選ぶかをユーザーが事前に設定できるようにする。
          # 設定されていなければ、ランダムで選ぶ
          word = user.books.first.words.shuffle.first
          client.reply_message(event['replyToken'], question(word))
        when 'question'
          word_name = query.slice(/wordName=.+/)
          word_name = word_name.gsub(/wordName=/, '')
          # TODO: wordをランダムに選ぶ処理が重複してるのでメソッドに切り出す。
          word = user.books.first.words.find_by(name: word_name)
          client.reply_message(event['replyToken'], confirm(word))
          # TODO: 正解、間違いの場合にDBを更新して成績をつけるようにする。
        when 'confirm'
          client.reply_message(event['replyToken'], menu(user))
        end
      end
    }

    head :ok
  end

  private

  def question(word)
    {
      "type": "template",
      "altText": "this is a confirm template",
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
      "altText": "this is a confirm template",
      "template": {
        "type": "confirm",
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

  def menu(user)
    {
      "type": "template",
      "altText": "this is a confirm template",
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
            "uri": "https://2eca44f8.ngrok.io/users/#{user.uid}/books/#{user.books.first.id}/words"
          }
        ]
      }
    }
  end
end
