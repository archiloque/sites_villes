# Importe la liste des populations des villes depuis les données de l'INSEE

require 'csv'
require_relative 'common'

CSV.foreach('../donnees/Commune_Insee_population.csv', {headers: true}) do |row|
  unless POPULATIONS.where(:code_insee => row['Code Insee']).first
    p row['Code Insee']
    POPULATIONS.insert(
        {
            :nom_ville => row['Nom de la commune'],
            :code_insee => row['Code Insee'],
            :population => row['Population municipale']
        })
  end
end
