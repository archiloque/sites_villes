# Importe les données des sites internet des mairies

# Télécharger le fichier all_latest.tar.bz2 à http://lecomarquage.service-public.fr/donnees_locales_v2/
# Et le copier dans le répertoire /donnees/organismes

require 'nokogiri'
require_relative 'common'

['../donnees/organismes/**/mairie-*.xml', '../donnees/organismes/75/paris_mairie*.xml'].each do |glob|
  Dir.glob(glob).each do |xml_file_path|
    File.open(xml_file_path, 'r') do |xml_file|
      doc = Nokogiri::XML(xml_file)
      code_insee = doc.at('Organisme')['codeInsee']
      nom_ville = doc.at('NomCommune').content
      url_site = doc.at('Url')
      if url_site
        url_site = url_site.content
      end
      unless VILLES.where(:code_insee => code_insee).first
        p "Insert #{code_insee}"
        VILLES.insert(
            {
                :nom_ville => nom_ville,
                :code_insee => code_insee,
                :url_site => url_site
            })
      end
    end
  end
end
