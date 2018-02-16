Sequel.migration do
  change do
    create_table(:assessments) do
      primary_key :id
      foreign_key :user_id, :users
      foreign_key :theme_id, :themes
      Date :answer_date
    end
  end
end
