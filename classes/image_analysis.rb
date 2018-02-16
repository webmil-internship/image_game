require 'net/http'
require "json"
require "dotenv/load"

class ImageAnalysis
  WRONG = 0.freeze
  DELAY = 'The task was to be sent by 00:00'.freeze
  DONE = 'You have already completed this task'.freeze
  NOT_YET = 'The task has not yet been issued'.freeze
  AZURE_URL = 'https://westcentralus.api.cognitive.microsoft.com/vision/v1.0/analyze'.freeze
  TELEGRAM_FILE_URL = 'https://api.telegram.org/file/bot' + ENV['TELEGRAM_TOKEN'] + '/'.freeze

  def initialize(image_path, user_id)
    @image_path = image_path
    @user = User.first(telegram_user_id: user_id.to_s)
  end

  def perform
    theme = Theme.last
    return NOT_YET unless theme
    today = Date.today
    return DELAY if theme.date != today
    return DONE unless Assessment.where(user_id: @user.id, theme_id: theme.id,
                                    answer_date: today).empty?
    'Your answer is ' + analyze.to_s
  end

  private

  def analyze
    uri = URI(AZURE_URL)
    uri.query = URI.encode_www_form({
      'visualFeatures' => 'Tags',
      'language' => 'en'
    })

    request = Net::HTTP::Post.new(uri.request_uri)
    request['Content-Type'] = 'application/json'
    request['Ocp-Apim-Subscription-Key'] = ENV['AZURE_API_KEY']
    file_path = TELEGRAM_FILE_URL + @image_path
    p file_path
    request.body = "{\"url\":\"#{file_path}\"}"

    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        http.request(request)
    end
    opinion = parse_details(JSON.parse(response.body)).round(2)

    Assessment.create(user_id: @user.id,
                      theme_id: Theme.last.id,
                      answer_date: Date.today,
                      opinion: opinion)
    opinion
  end

  def parse_details(details)
    if Theme.last
      details['tags'].each do |detail|
        if detail.value?(Theme.last.title)
          return detail['confidence']
        end
      end
    end
    return WRONG
  end
end
