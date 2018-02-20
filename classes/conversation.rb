class Conversation

  SEPARATOR = "\n".freeze
  INSTRUCTION = 'The essence of the game: we send you a message with task and' +
                'you must do photo of the subject from the task. New task begin' +
                'at 09:00 every day and lasts till 23:59, after that, the' +
                'answers will not be accepted. WARNING: Your first photo will' +
                'be considered for the final answer. We will evaluate the completed' +
                'task and immediately send you a score on a scale from 0 to 1.' +
                'You can see the overall score of points by writing /rating'.freeze
  LAST_TASK = '/last - display last task'.freeze
  NOONE = 'There are no players in this game yet'.freeze
  NOT_START = 'You have not started the game, enter /start to start'.freeze
  CONTINUE = 'To continue the game enter /start'.freeze
  HELP = ['/start - start the game', '/stop - deactivate accepting messages',
          '/rules - display the rules of the game', '/help - display help',
          '/rating - display rating', '/last - display the last task'].freeze
  MESSAGE_FOR_UNDEFINED_COMMAND = "We don't understand your command, " +
                                  'enter /help to view available commands'.freeze

  def initialize(message, bot)
    @bot = bot
    @message = message
    @user = message.from
  end

  def to_new_user
    if start_game
      @bot.api.send_message(chat_id: @user.id, text: "Hello, #{@user.first_name}.")
      send_rules
    else
      @bot.api.send_message(chat_id: @user.id, text: "User with this telegram id already exist")
    end
  end

  def say_bye_to_user
    user = User.first(telegram_user_id: @user.id.to_s)
    if user
      user.update(is_active: false)
      @bot.api.send_message(chat_id: @user.id, text: "Bye, #{user.first_name}. " + CONTINUE)
    else
      @bot.api.send_message(chat_id: @user.id, text: NOT_START)
    end
  end

  def send_opinion_to_user
    answer = analyze
    @bot.api.send_message(chat_id: @user.id, text: answer)
  end

  def send_rating
    count = Theme.count
    rating = []
    DB.fetch("SELECT users.first_name, SUM(assessments.opinion)/#{count} AS rating
              FROM users
              INNER JOIN assessments ON (users.id = assessments.user_id)
              GROUP BY users.first_name
              ORDER BY rating DESC") do |row|
      rating << row.values.join(' ')
    end
    if rating.any?
      message = rating.join(SEPARATOR)
    else
      message = NOONE
    end
    @bot.api.send_message(chat_id: @user.id, text: message)
  end

  def send_help
    @bot.api.send_message(chat_id: @user.id, text: HELP.join(SEPARATOR))
  end

  def send_rules
    @bot.api.send_message(chat_id: @user.id, text: INSTRUCTION)
  end

  def send_last_task
    @bot.api.send_message(chat_id: @user.id, text: Task.get_last)
  end

  def undefined_command
    @bot.api.send_message(chat_id: @user.id, text: MESSAGE_FOR_UNDEFINED_COMMAND)
  end

  private

  def create_user
    User.create(telegram_user_id: @user.id, first_name: @user.first_name,
                last_name: @user.last_name, username: @user.username,
                language_code: @user.language_code,
                is_active: true)
  end

  def start_game
    user = User.first(telegram_user_id: @user.id.to_s, is_active: false)
    if user
      user.update(is_active: true)
      true
    else
      create_user
    end
  end

  def analyze
    photo = @bot.api.get_file(file_id: @message.photo.last.file_id)
    ImageAnalysis.new(photo['result']['file_path'], @message.from.id).perform
  end
end
