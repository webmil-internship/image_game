require 'date'

class Task
  TASKS = ['car', 'bed', 'computer', 'monitor', 'room', 'balcony'].freeze
  TASK = 'Your task today is '.freeze
  OOPS = 'The game has not started yet'.freeze

  def perform
    task = create_theme
    Telegram::Bot::Client.run(ENV['TELEGRAM_TOKEN']) do |bot|
      User.where(is_active: true).each do |user|
        bot.api.send_message(chat_id: user.telegram_user_id, text: task_message(user, task.title))
      end
    end
  end

  def generate_taks
    Theme.create(title: TASKS.sample, date: Date.today)
  end

  def self.get_last
    if Theme.last
      TASK + Theme.last.title
    else
      OOPS
    end
  end

  private

  def task_message(user, title)
    "Dear #{user.first_name}. Your task today is " + title
  end

  def create_theme
    unless User.empty? || User.where(is_active: true).empty?
      last_themes = Theme.last(3).map(&:title)
      Theme.create(title: (TASKS - last_themes).sample, date: DateTime.now)
    end
  end
end
