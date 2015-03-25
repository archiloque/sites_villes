# Info sur l'hébergement

# select key, count(*) c from headers group by key order by c desc;
require_relative 'common'
require 'nokogiri'

HEADERS = DB[:headers]
SITES = DB[:sites]
SYSTEMS = DB[:systems]
VILLES = DB[:villes]

PHP_REGEX = /\APHP\/(\d+)\.(\d+)\.(\d+)/
PHP_REGEX_PARENS = /\A\(PHP\/(\d+)\.(\d+)\.(\d+)/
SPIP_REGEX = /\ASPIP ([^ ]+) @ www.spip.net/
SPIP_LONG_REGEX = /\ASPIP ([^ ]+) ([^ ]+) @ www.spip.net/
APACHE_REGEX = /\AApache\/(\d+)\.(\d+)\.(\d+)/
APACHE_SHORT_REGEX = /\AApache\/(\d+)\.(\d+)/
APACHE_PROXAD_REGEX = /\AApache\/ProXad \[[A-Z][a-z][a-z] \d\d \d\d\d\d \d\d:\d\d:\d\d\]\z/
IIS_REGEX = /\AMicrosoft-IIS\/(\d+)\.(\d+)/
LIGHTTPD_REGEX = /\Alighttpd\/(\d+)\.(\d+)\.(\d+)/
NGINX_REGEX = /\Anginx\/(\d+)\.(\d+)\.(\d+)/
WP_ROCKET_REGEX = /\AWP Rocket\/\d\.\d\.\d/
W3_TOTAL_CACHE_1_REGEX = /\AW3 Total Cache\/\d\.\d\.\d\.\d/
W3_TOTAL_CACHE_2_REGEX = /\AW3 Total Cache\/\d\.\d\.\d/
TYPO3_CMS_REGEX = /\ATYPO3 (\d)\.(\d) CMS/
WORDPRESS_1_REGEX = /\AWordPress (\d)\.(\d).(\d)/
WORDPRESS_2_REGEX = /\AWordPress (\d)\.(\d)/
JOOMLA_REGEX = /\AJoomla! (\d)\.(\d) - Open Source Content Management/
SPIP_GENERATOR_1_REGEX = /\ASPIP (\d)\.(\d+)\.(\d+) \[\d+\]/
SPIP_GENERATOR_2_REGEX = /\ASPIP (\d)\.(\d+)\.(\d+)/
IZISPOT_REGEX = /\AIziSpot (\d)\.(\d+) \(www\.izispot\.com\)/
SYSTEMS.delete

def update_system(ville_id, values)
	SYSTEMS.where("id = ?", system_id(ville_id)).update(values)
end

def ville_id_from_header(header)
	SITES.where('id = ?', header[:site_id]).first[:ville_id]
end

def system_id(ville_id)
	system = SYSTEMS.where('ville_id = ?', ville_id).first
	if system
		system[:id]
	else
		SYSTEMS.insert(
        {
            :ville_id => ville_id
        })
		SYSTEMS.where('ville_id = ?', ville_id).first[:id]
	end
end

def print_unknown(values)
	values.to_a.sort{|a, b| b[1].length <=> a[1].length}.each do |entry|
		p "#{entry[1].length} [#{entry[0]}] #{entry[1].collect{|i| "[#{i}]"}.join(' ')}"
	end
end

unknown = Hash.new { |hash, key| hash[key] = [] }
p '****** Generator'
GENERATOR_HARDCODED_LIST = {
	'Drupal 7 (http://drupal.org)' => {:language => 'php', :application => 'Drupal', :application_version => '7'},
	'Joomla! - Open Source Content Management' => {:language => 'php', :application => 'Joomla'},
	'SPIP' => {:language => 'php', :application => 'SPIP'},
	'e.magnus site web Solo X8 - www.magnus.fr/emagnus/emagnus-siteweb' => {:application => 'e.Magnus'},
	'e.magnus site web Multiposte X8 / www.magnus.fr/emagnus/emagnus-siteweb' => {:application => 'e.Magnus'},
	'e.magnus site web Multiposte / www.magnus.fr/emagnus/emagnus-siteweb' => {:application => 'e.Magnus'},
	'e.magnus site web Solo - www.magnus.fr/emagnus/emagnus-siteweb' => {:application => 'e.Magnus'},
	'Creaville 3.0 - http://www.creaville.com' => {:application => 'Creaville'},
	'eZ publish' => {:language => 'php', :application => 'eZ Publish'},
	'eZ Publish' => {:language => 'php', :application => 'eZ Publish'},
	'WebSee (imaweb.fr)' => {:language => 'php', :application => 'WebSee'},
	'e-monsite (e-monsite.com)' => {:application => 'WebSee'},
	'1&1 DIY Websitebuilder' => {:application => '1&1 DIY Websitebuilder'},
	'WEBDEV' => {:application => 'WebDev'},
	'Powered by Visual Composer - drag and drop page builder for WordPress.' => {:language => 'php', :application => 'WordPress',},
	'GuppY CMS' => {:language => 'php', :application => 'GuppY'},
	'TYPO3 CMS' => {:language => 'php', :application => 'TYPO3'},
	'blogger' => {:application => 'Blogger'},
	'IziSpot 4.51 (www.izispot.com)' => {:application => 'IziSpot'},
	'XOOPS' => {:application => 'XOOPS', :language => 'php'},
	'Isotools Studio - http://www.isotools.com' => {:application => 'Isotools Studio'},
	'CanalBlog - http://www.canalblog.com' => {:application => 'CanalBlog'},
	'WebExpert 2000' => {:application => 'WebExpert 2000'},
}
IGNORED_GENERATOR = ['ORT - Ovh Redirect Technology', 'Tribal-Dolphin Meta-Gen', 'logiciels', '']

def identify_generator(generator_value, ville_id, unknown)
	if result = GENERATOR_HARDCODED_LIST[generator_value]
		update_system(ville_id, result)
	elsif IGNORED_GENERATOR.include? generator_value
	elsif m = TYPO3_CMS_REGEX.match(generator_value)
		update_system(ville_id, {
			:language => 'php',
			:application => 'TYPO3',
			:application_version => "#{m[1]}.#{m[2]}"
		})
	elsif m = WORDPRESS_1_REGEX.match(generator_value)
		update_system(ville_id, {
			:language => 'php',
			:application => 'WordPress',
			:application_version => "#{m[1]}.#{m[2]}.#{m[3]}"
		})
	elsif m = WORDPRESS_2_REGEX.match(generator_value)
		update_system(ville_id, {
			:language => 'php',
			:application => 'WordPress',
			:application_version => "#{m[1]}.#{m[2]}"
		})
	elsif m = JOOMLA_REGEX.match(generator_value)
		update_system(ville_id, {
			:language => 'php',
			:application => 'Joomla',
			:application_version => "#{m[1]}.#{m[2]}"
		})
	elsif m = SPIP_GENERATOR_1_REGEX.match(generator_value)
		update_system(ville_id, {
			:language => 'php',
			:application => 'SPIP',
			:application_version => "#{m[1]}.#{m[2]}.#{m[3]}"
		})
	elsif m = SPIP_GENERATOR_2_REGEX.match(generator_value)
		update_system(ville_id, {
			:language => 'php',
			:application => 'SPIP',
			:application_version => "#{m[1]}.#{m[2]}.#{m[3]}"
		})
	elsif m = IZISPOT_REGEX.match(generator_value)
		update_system(ville_id, {
			:application => 'IziSpot',
			:application_version => "#{m[1]}.#{m[2]}"
		})
	else
		ville = VILLES.where('id = ?', ville_id).first
		unknown[generator_value] << ville[:url_site]
	end
end

def identify_link(link, ville_id)
	if link.include? 'wp-content/'
		update_system(ville_id, {
			:language => 'php',
			:application => 'WordPress'
		})
		true
	elsif link.include? 'squelettes/'
		update_system(ville_id, {
			:language => 'php',
			:application => 'SPIP'
		})
		true
	else
		false
	end
end


SITES.each do |site|
	if (site[:code] != 0) && site[:content]
		doc = Nokogiri::HTML(site[:content])
		ville_id = site[:ville_id]
		doc.xpath("//meta[@name='generator']/@content").each do |generator|
  			identify_generator(generator.value, ville_id, unknown)
		end
		doc.xpath("//script").any? do |script|
			src = script['src']
			if src && identify_link(src, ville_id)
				true
  			else
  				false
  			end
		end
		doc.xpath("//link[@rel='stylesheet']").any? do |stylesheet|
			href = stylesheet['href']
			if href && identify_link(href, ville_id)
				true
  			else
  				false
  			end
		end

	end
end
print_unknown(unknown)
p ''

POWERED_BY_HARDCODED_LIST = {
	'php' => {:language => 'php'},
	'ASP.NET' => {:language => 'asp.net'},
	'(ASP.NET,PleskWin)' => {:language => 'asp.net'},
	'eZ Publish' => {:language => 'php', :application => 'eZ Publish'},
	'eZ publish' => {:language => 'php', :application => 'eZ Publish'},
	'yacs (http://www.yacs.fr/)' => {:language => 'php', :application => 'Yacs'},
}
IGNORED_POWERED_BY = ['PleskLin', '']

unknown = Hash.new { |hash, key| hash[key] = [] }
p '****** X-Powered-By'
HEADERS.where('key = ?', 'X-Powered-By').each do |header|
	header_value = header[:value]
	ville_id = ville_id_from_header(header)
	if m = PHP_REGEX.match(header_value)
		update_system(ville_id, {
			:language => 'php',
			:language_version => "#{m[1]}.#{m[2]}.#{m[3]}"
		})
	elsif m = PHP_REGEX_PARENS.match(header_value)
		update_system(ville_id, {
			:language => 'php',
			:language_version => "#{m[1]}.#{m[2]}.#{m[3]}"
		})
	elsif result = POWERED_BY_HARDCODED_LIST[header_value]
		update_system(ville_id, result)
	elsif WP_ROCKET_REGEX.match(header_value) || W3_TOTAL_CACHE_1_REGEX.match(header_value) || W3_TOTAL_CACHE_2_REGEX.match(header_value)
		update_system(ville_id, {
			:language => 'php',
			:application => 'WordPress'
		})
	elsif IGNORED_POWERED_BY.include? header_value
	else
		ville = VILLES.where('id = ?', ville_id).first
		unknown[header_value] << ville[:url_site]
	end
end
print_unknown(unknown)
p ''

COMPOSED_BY_HARDCODED_LIST = {
	'SPIP @ www.spip.net' => {:language => 'php', :application => 'SPIP'},
}
unknown = Hash.new { |hash, key| hash[key] = [] }
p '****** Composed-By'
HEADERS.where('key = ?', 'Composed-By').each do |header|
	header_value = header[:value]
	ville_id = ville_id_from_header(header)
	if m = SPIP_REGEX.match(header_value)
		update_system(ville_id, {
			:language => 'php',
			:application => 'SPIP',
			:application_version => "#{m[1]}"
		})
	elsif m = SPIP_LONG_REGEX.match(header_value)
		update_system(ville_id, {
			:language => 'php',
			:application => 'SPIP',
			:application_version => "#{m[1]} #{m[2]}"
		})
	elsif result = COMPOSED_BY_HARDCODED_LIST[header_value]
		update_system(ville_id, result)
	else
		ville = VILLES.where('id = ?', ville_id).first
		unknown[header_value] << ville[:url_site]
	end
end
print_unknown(unknown)
p ''

unknown = Hash.new { |hash, key| hash[key] = [] }
p '****** Server'
SERVERS_HARDCODED_LIST = {
	'GSE' => {:server => 'Google'},
	'nginx' => {:server => 'Nginx'},
	'Apache-Coyote/1.1' => {:server => 'Apache Tomcat'},
	'IcodiaSecureHttpd' => {:server => 'Icodia'},
	'WMaker/Prod' => {:server => 'WMaker'},
	'Tengine' => {:server => 'Tengine'},
	'Lotus-Domino' => {:server => 'Lotus-Domino'},
	'LiteSpeed' => {:server => 'LiteSpeed'},
	'Microsoft IIS7' => {:server => 'IIS', :server_version => '7'},
	'o2switch PowerBoost Server v2.6.000 - Build 211120141025' => {:server => 'o2switch'},
	'SiteW Webserver 1.2.0' => {:server => 'SiteW'},
	'Apache' => {:server => 'Apache'},
	'Apache/2' => {:server => 'SiteW', :server_version => '2'},
	'Apache 1.3.xx' => {:server => 'SiteW', :server_version => '1.3'},
	'lighttpd' => {:server => 'Lighttp'},
}
IGNORED_SERVERS = ['Varnish', 'Mutu-Nerim', 'none', '']

HEADERS.where('key = ?', 'Server').each do |header|
	header_value = header[:value]
	ville_id = ville_id_from_header(header)
	if m = APACHE_SHORT_REGEX.match(header_value)
		update_system(ville_id, {
			:server => 'Apache',
			:server_version => "#{m[1]}.#{m[2]}"
		})
	elsif m = APACHE_REGEX.match(header_value)
		update_system(ville_id, {
			:server => 'Apache',
			:server_version => "#{m[1]}.#{m[2]}.#{m[3]}"
		})
	elsif m = APACHE_PROXAD_REGEX.match(header_value)
		update_system(ville_id, {
			:server => 'Apache'
		})
	elsif m = LIGHTTPD_REGEX.match(header_value)
		update_system(ville_id, {
			:server => 'Lighttp',
			:server_version => "#{m[1]}.#{m[2]}.#{m[3]}"
		})
	elsif m = NGINX_REGEX.match(header_value)
		update_system(ville_id, {
			:server => 'Nginx',
			:server_version => "#{m[1]}.#{m[2]}.#{m[3]}"
		})
	elsif m = IIS_REGEX.match(header_value)
		update_system(ville_id, {
			:server => 'IIS',
			:server_version => "#{m[1]}.#{m[2]}"
		})
	elsif result = SERVERS_HARDCODED_LIST[header_value]
		update_system(ville_id, result)
	elsif IGNORED_SERVERS.include? header_value
	else
		ville = VILLES.where('id = ?', ville_id).first
		unknown[header_value] << ville[:url_site]
	end
end
print_unknown(unknown)

# Headers customs
HEADERS.where('key = ?', 'X-Wix-Dispatcher-Cache-Hit').each do |header|
	ville_id = ville_id_from_header(header)
	update_system(ville_id, {:server => 'Wix'})
end


