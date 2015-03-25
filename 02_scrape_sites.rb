# Scrappe tous les sites des mairies et stocke les résultats

require 'typhoeus'
require 'ruby-progressbar'

require_relative 'common'

SITES = DB[:sites]
HEADERS = DB[:headers]

#SITES.where('code != 200').each do |site|
#    HEADERS.where('site_id = ?', site[:id]).delete
#    SITES.where('id = ?', site[:id]).delete
#end

#HEADERS.delete
#SITES.delete

sites_number = 0
progress_bar = ProgressBar.create({format: '%J%% %a%e |%B|'})
hydra = Typhoeus::Hydra.new(max_concurrency: 5)
DB[:villes].where('url_site is not null and id not in (select ville_id from sites)').each do |ville|
  sites_number += 1
  request = Typhoeus::Request.new(ville[:url_site], followlocation: true, timeout: 60)
  request.on_complete do |response|
    progress_bar.increment
    ville_id = ville[:id]
    if response.timed_out?
      code = 0
      content = 'Timeout'
    elsif response.code == 0
      code = 0
      content = response.return_message
    else
      p ville
      code = response.code.to_s
      content = response.body
    end
    SITES.insert({
        :ville_id => ville_id,
        :code => code,
        :content => content.encode_brutal
    })

    inserted_site = SITES.where(:ville_id => ville_id).first
    site_id = inserted_site[:id]
    HEADERS.multi_insert(response.headers.to_a.collect{ |pair| {:site_id => site_id, :key => pair[0], :value => pair[1]}})
  end
  hydra.queue request
end
progress_bar.total = sites_number
hydra.run
