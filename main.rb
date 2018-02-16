require 'telegram/bot'
require 'dotenv/load'
require 'rufus-scheduler'
require_relative 'db/connection'
require_relative 'classes/image_analysis'
require_relative 'classes/task'
require_relative 'classes/scheduler'
require_relative 'classes/conversation'
require_relative 'models/user'
require_relative 'models/theme'
require_relative 'models/assessment'
# START = '/start'.freeze
# STOP = '/start'.freeze
# RATING = '/start'.freeze
# HELP = '/start'.freeze
# RULES = '/start'.freeze
# LAST = '/start'.freeze

Scheduler.call

Telegram::Bot::Client.run(ENV['TELEGRAM_TOKEN']) do |bot|
  bot.listen do |message|
    conversation = Conversation.new(message, bot)
    if message.photo.any?
      conversation.send_opinion_to_user
    end
    case message.text
    when '/start'
      conversation.to_new_user
    when '/stop'
      conversation.say_bye_to_user
    when '/rating'
      conversation.send_rating
    when '/help'
      conversation.send_help
    when '/rules'
      conversation.send_rules
    when '/last'
      conversation.send_last_task
    end
  end
end
