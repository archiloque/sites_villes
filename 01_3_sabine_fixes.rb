# Importe les données des sites internet des mairies

# Télécharger le fichier all_latest.tar.bz2 à http://lecomarquage.service-public.fr/donnees_locales_v2/
# Et le copier dans le répertoire /donnees/organismes

require 'nokogiri'
require_relative 'common'
require 'csv'

SITES = DB[:sites]
VILLES = DB[:villes]
HTTPS = DB[:https]
HEADERS = DB[:headers]
SYSTEMS = DB[:systems]

CSV.foreach("extraction_villes_sabine.csv", col_sep: ',', headers: true) do |row|
  code_insee = row['code insee']
  if code_insee.length == 4
    code_insee = "0#{code_insee}"
  end
  nom_ville = row['nom ville']
  url = row['url']

  ville = VILLES.where(code_insee: code_insee).first
  unless ville
    p row
    exit -1
  end
  if (ville[:nom_ville] != nom_ville) || (ville[:url_site] != url)
    p "Update [#{row}]"
    ville_id = ville[:id]
    if SITES.where(:ville_id => ville_id).first
      site_id = SITES.where(:ville_id => ville_id).first[:id]
      HEADERS.where(:site_id => site_id).delete
    end
    SYSTEMS.where(:ville_id => ville_id).delete
    HTTPS.where(:ville_id => ville_id).delete
    SITES.where(:ville_id => ville_id).delete
    VILLES.where('id = ?', ville_id).update(
        {
            :url_site => url,
            :nom_ville => nom_ville
        })
  end
end
