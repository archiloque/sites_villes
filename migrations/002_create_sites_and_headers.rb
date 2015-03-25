Sequel.migration do
	up do
		create_table :sites do
			primary_key :id
			foreign_key :ville_id, :villes
			Integer :code, :index => true, :null => false
			String :content, :text=>true
		end

		create_table :headers do
			primary_key :id
			foreign_key :site_id, :sites
			String :key, :text=>true, :index => true, :null => false
			String :value, :text=>true, :index => true, :null => false
		end
	end
end