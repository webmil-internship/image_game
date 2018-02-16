Sequel.migration do
  change do
    create_table(:themes) do
      primary_key :id
      String :title
      Date :date
    end
  end
end
