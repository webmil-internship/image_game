Sequel.migration do
  change do
    add_column :assessments, :opinion, Float
  end
end
