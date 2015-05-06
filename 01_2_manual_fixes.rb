# Importe les données des sites internet des mairies

# Télécharger le fichier all_latest.tar.bz2 à http://lecomarquage.service-public.fr/donnees_locales_v2/
# Et le copier dans le répertoire /donnees/organismes

require 'nokogiri'
require_relative 'common'

# Manual fixes:
[
    ['64001', 'http://www.aast.free.fr'],
    ['62072', 'http://mairie.bailleulmont.free.fr'],
    ['77348', 'http://mairie.ormesson.free.fr/'],
    ['41039', 'http://chapellesaintmartin.free.fr'],
    ['35200', nil],
    ['50546', 'http://www.st-samson.fr'],
    ['32362', 'http://saintaunix.wix.com/la-liste-de-saint-aunix-lengros'],
    ['50519', 'http://stmartinlegreard.free.fr'],
    ['02009', 'http://alaincourt-aisne.fr'],
    ['22236', 'http://mairie.pludual.free.fr'],
    ['21546', nil],
    ['81303', 'http://www.trebaslesbains.com'],
    ['81102', 'http://garrigues81.free.fr'],
    ['86150', 'http://massognes.free.fr'],
    ['21253', 'http://etalante.commune.free.fr'],
    ['18118', 'http://mairie.jouet.free.fr'],
    ['50123', 'http://lachapelle.enjuger.free.fr'],
    ['18120', 'http://mairie.jussy18.free.fr'],
    ['89139', 'http://diges.free.fr'],
    ['28060', 'http://briconville.free.fr'],
    ['52488', nil],
    ['68059', 'http://burnhaupt.free.fr'],
    ['68205', 'http://meyenheim.free.fr/index2.html'],
    ['71470', 'http://mairie.stpoint.free.fr/infosgenerales.php'],
    ['08466', 'http://vaux-les-mouzon.monsite-orange.fr'],
    ['52240', 'http://heuilleylegrand.free.fr'],
    ['07138', 'http://www.lavilledieu-ardeche.fr'],
    ['39198', 'http://www.doledujura.fr/'],
    ['44215', 'http://www.vertou.fr'],
    ['78358', 'http://www.maisonslaffitte.fr'],
    ['84054', 'http://www.islesurlasorgue.fr'],
    ['97309', 'http://remire-montjoly.mairies-guyane.org'],
    ['59421', 'http://www.mouvaux.fr'],
    ['74133', 'http://www.gaillard.fr'],
    ['97125', 'http://www.villedesaintfrancois.fr/'],

    ['97613', 'http://www.mtsangamouji.fr'],
    ['28110', 'http://www.mairie-matoury.fr'],
    ['97414', 'http://saintlouis.re'],
    ['97304', 'http://www.kourou.fr'],
    ['97128', 'http://www.ville-sainteanne.fr'],
    ['97129', 'http://www.sainte-rose.org'],
    ['97207', 'http://www.ville-ducos.fr'],
    ['13014', 'http://www.berre-l-etang.fr/web/'],
    ['59527', 'http://www.villesaintandre.fr'],
    ['93030', 'http://www.ville-dugny.fr'],
    ['59616', 'http://www.ville-vieux-conde.fr'],
    ['06084', 'http://www.mouans-sartoux.net'],
    ['62587', 'http://www.mairie-montigny.fr'],

    ['69384', 'http://www.mairie4.lyon.fr/page/accueil_4.html'],
    ['69385', 'http://www.mairie5.lyon.fr/page/accueil_5.html'],
    ['69387', 'http://www.mairie5.lyon.fr/page/accueil_7.html'],
    ['69388', 'http://www.mairie8.lyon.fr/page/accueil_8.html'],

].each do |pair|
  unless VILLES.where('code_insee = ? and url_site = ?', pair[0], pair[1]).first
    p "Update #{pair}"
    ville_id = VILLES.where('code_insee = ?', pair[0]).first[:id]
    if SITES.where(:ville_id => ville_id).first
      site_id = SITES.where(:ville_id => ville_id).first[:id]
      HEADERS.where(:site_id => site_id).delete
    end
    SYSTEMS.where(:ville_id => ville_id).delete
    HTTPS.where(:ville_id => ville_id).delete
    SITES.where(:ville_id => ville_id).delete
    VILLES.where('code_insee = ?', pair[0]).update(
        {
            :url_site => pair[1]
        })
  end
end

# update villes set nom_ville = 'Ville de Paris' where code_insee = '75056';