class User < Sequel::Model
  plugin :validation_helpers
  one_to_many :assessments
  def validate
    super
    validates_unique :telegram_user_id
  end
end
