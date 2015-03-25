# Statististique de site par taille de ville

require 'csv'
require_relative 'common'

result = Hash.new { |hash, key| hash[key] = {total: 0, avec_site: 0} }
POPULATIONS = DB[:populations]
population_by_insee = {}
POPULATIONS.each do |population|
	population_by_insee[population[:code_insee]] = population[:population]
end

SITES = DB[:sites]
DB[:villes].each do |ville|
	code_insee = ville[:code_insee]
	population_ville = population_by_insee[code_insee]
	if population_ville
    if population_ville < 1000
      population_bucket = (population_ville.to_f / 100).to_i * 100
    elsif population_ville >= 10000
        population_bucket = 10000
    else
      population_bucket = (population_ville.to_f / 1000).to_i * 1000
    end
		bucket = result[population_bucket]
		bucket[:total] += 1
		if SITES.where('ville_id = ? and code = 200', ville[:id]).first
			bucket[:avec_site] += 1
    else
      if population_ville > 5000
        p "#{population_ville} #{ville}"
      end
		end
	else
		p "Population non trouvée #{ville}"
	end
end

CSV.open("../resultats/sites_par_taille.csv", "wb") do |csv|
  csv << ["Taille", "Proportion", "Nombre"]
  result.keys.sort.each do |bucket|
  	value = result[bucket]
  	csv << [
  		bucket,
  		(value[:avec_site].to_f / value[:total].to_f * 100).to_i,
  		value[:total]
  	]
  end
end