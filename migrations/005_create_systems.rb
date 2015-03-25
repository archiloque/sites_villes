Sequel.migration do
	up do
		create_table :systems do
			primary_key :id
			foreign_key :ville_id, :villes
			String :server
			String :server_version
			String :application
			String :application_version
			String :language
			String :language_version
		end
	end
end
