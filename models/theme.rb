class Theme < Sequel::Model
  one_to_many :assessment
end
