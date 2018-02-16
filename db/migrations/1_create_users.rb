Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :telegram_user_id
      String :first_name
      String :last_name
      String :username
      String :language_code
      TrueClass :is_active
    end
  end
end
