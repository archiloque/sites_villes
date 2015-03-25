Sequel.migration do
	up do
		create_table :populations do
			primary_key :id
			String :nom_ville, :unique => false, :null => false
			String :code_insee, :index => true, :unique => true, :null => false
 			Integer :population, :null => false
 		end
	end
end