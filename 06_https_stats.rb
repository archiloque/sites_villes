# Stats sur les versions https

require 'addressable/uri'
require_relative 'common'

HTTPS = DB[:https]

total = 0
valids = 0
HTTPS.where('ville_id in (select ville_id from sites where code = 200)').each do |https_result|
  total += 1
  if https_result[:code] == 200
    if Addressable::URI.parse(https_result[:uri_reelle]).scheme == 'https'
      valids += 1
    end
  end
end
p "Total: #{total}"
p "Valid: #{valids}"
p "Percent: #{((valids.to_f / total.to_f * 10000).to_i).to_f / 100}"

# select uri_reelle, nom_ville, code_insee, systems.*
# from https, villes, systems
# where https.uri_reelle like 'http://?'
# and https.code = 200
# and https.ville_id = villes.id
# and systems.ville_id = villes.id