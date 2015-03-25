Sequel.migration do
	up do
		create_table :https do
			primary_key :id
			foreign_key :ville_id, :villes
			Integer :code, :index => true, :null => false
			String :uri, :text=>true, :null => false
			String :uri_reelle, :text=>true, :null => false
			String :content, :text=>true
		end
	end
end
