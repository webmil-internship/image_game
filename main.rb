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
START_COMMAND = '/start'.freeze
STOP_COMMAND = '/stop'.freeze
RATING_COMMAND = '/rating'.freeze
HELP_COMMAND = '/help'.freeze
RULES_COMMAND = '/rules'.freeze
LAST_TASK_COMMAND = '/last'.freeze

Scheduler.call

Telegram::Bot::Client.run(ENV['TELEGRAM_TOKEN']) do |bot|
  bot.listen do |message|
    conversation = Conversation.new(message, bot)
    case message.text
    when START_COMMAND
      conversation.to_new_user
    when STOP_COMMAND
      conversation.say_bye_to_user
    when RATING_COMMAND
      conversation.send_rating
    when HELP_COMMAND
      conversation.send_help
    when RULES_COMMAND
      conversation.send_rules
    when LAST_TASK_COMMAND
      conversation.send_last_task
    else
      if message.photo.any?
        conversation.send_opinion_to_user
      else
        conversation.undefined_command
      end
    end
  end
end
