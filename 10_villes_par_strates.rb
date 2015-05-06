# Statististique de site par taille de ville

require 'csv'
require_relative 'common'

STRATES =
    [
        {nom: '0 – 2.000', nombre: 2000},
        {nom: '2.000 – 10.000', nombre: 10000},
        {nom: '10.0000 – 50.000', nombre: 50000},
        {nom: '50.000 - 100.000', nombre: 100000},
        {nom: 'Plus de 100.000', nombre: 99999999999},
    ]


def strate_ville?(population_ville)
  STRATES.find do |entry|
    entry[:nombre] > population_ville
  end[:nom]
end

result = Hash.new { |hash, key| hash[key] = Hash.new(0) }
population_by_insee = {}
POPULATIONS.each do |population|
	population_by_insee[population[:code_insee]] = population[:population]
end

VILLES.each do |ville|
	code_insee = ville[:code_insee]
	population_ville = population_by_insee[code_insee]
	if population_ville
    strate_ville = strate_ville?(population_ville)
    result[strate_ville][ville[:category]] += 1
	else
		p "Population non trouvée #{ville}"
	end
end

CSV.open("../resultats/villes_par_strate.csv", 'w:UTF-8') do |csv|
  csv << (["Taille", "Total"] + CATEGORIES_SITES)
  result.keys.sort.each do |bucket|
    values = result[bucket]
    total = values.values.inject(:+)
    csv << ([bucket, total] + CATEGORIES_SITES.collect{|c| values[c]})
  end
end