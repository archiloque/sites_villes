Sequel.migration do
	up do
		create_table :villes do
			primary_key :id
			String :nom_ville, :index => true, :unique => false, :null => false
			String :code_insee, :index => true, :unique => true, :null => false
 			String :url_site, :index => true, :unique => false, :null => true
 		end
	end
end