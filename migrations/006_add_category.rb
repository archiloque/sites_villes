Sequel.migration do
  up do
    add_column :villes, :category, String
  end
  down do
    drop_column :villes, :category
  end
end