class Assessment < Sequel::Model
  many_to_one :user
  many_to_one :themes
end
