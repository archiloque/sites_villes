# Teste les versions https

require 'typhoeus'
require 'ruby-progressbar'
require 'addressable/uri'

require_relative 'common'

#HTTPS.delete

sites_number = 0
progress_bar = ProgressBar.create({format: '%J%% %a%e |%B|'})
hydra = Typhoeus::Hydra.new(max_concurrency: 50)
VILLES.where('url_site is not null and id not in (select ville_id from https)').each do |ville|
  sites_number += 1
  original_url = ville[:url_site]
  addressable_uri = Addressable::URI.heuristic_parse(original_url)
  addressable_uri.scheme = 'https'
  uri = addressable_uri.to_s
  request = Typhoeus::Request.new(uri, followlocation: true, timeout: 60)
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
      code = response.code.to_s
      content = response.body
    end
    HTTPS.insert({
        :ville_id => ville_id,
        :code => code,
        :content => content.encode_brutal,
        :uri => uri,
        :uri_reelle => response.effective_url.encode_brutal
    })
  end
  hydra.queue request
end
progress_bar.total = sites_number
hydra.run
