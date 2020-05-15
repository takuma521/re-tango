require 'uri'
require 'json'

class Translate
  def self.to_japanese(context)
    url = URI.parse('https://www.googleapis.com/language/translate/v2')
    params = {
      q: context,
      target: 'ja',
      source: 'en',
      key: Rails.application.credentials.google[:cloud_api_key]
    }
    url.query = URI.encode_www_form(params)
    res = Net::HTTP.get_response(url)
    json = res.body
    JSON.parse(json)['data']['translations'].first['translatedText']
  end
end
