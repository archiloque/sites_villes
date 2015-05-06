# Info sur les systèmes
require 'csv'
require_relative 'common'
require 'set'

total = 0
stats_language = Hash.new(0)
stats_language_version = Hash.new(0)
stats_application = Hash.new(0)
stats_application_version = Hash.new(0)
stats_server = Hash.new(0)
stats_server_version = Hash.new(0)

STRATES =
    [
        {nom: '0 – 2.000', nombre: 2000},
        {nom: '2.000 – 10.000', nombre: 10000},
        {nom: '10.0000 – 50.000', nombre: 50000},
        {nom: 'Plus de 50.000', nombre: 99999999999},
    ]

def strate_ville(population_ville)
  STRATES.find do |entry|
    entry[:nombre] > population_ville
  end[:nom]
end

SUPPORTED_PHP_LONG = SUPPORTED_PHP_VERSIONS.collect { |v| "php #{v}" }
UNSUPPORTED_PHP_LONG = UNSUPPORTED_PHP_VERSIONS.collect { |v| "php #{v}" }

def status_php(version)
  if SUPPORTED_PHP_LONG.include? version
    'supporte'
  elsif UNSUPPORTED_PHP_LONG.include? version
    'non supporte'
  else
    'inconnu'
  end

end

versions_php = Hash.new { |hash, key| hash[key] = Hash.new(0) }
versions_php_groupe = Hash.new { |hash, key| hash[key] = Hash.new(0) }
strates = Set.new

SITES.where('code = 200').each do |site|
  total += 1
  language = ''
  language_version = ''
  application = ''
  application_version = ''
  server = ''
  server_version = ''
  system = SYSTEMS.where('ville_id = ?', site[:ville_id]).first
  if system
    language = system[:language] || ''
    if (language_version = system[:language_version])
      language_version = "#{language} #{language_version}"
      if language == 'php'
        if population = POPULATIONS.where('populations.code_insee = (select villes.code_insee from villes where id = ?)', site[:ville_id]).first
          population = population[:population]
          strate_population = strate_ville(population)
          versions_php[language_version][strate_population] += 1
          versions_php_groupe[status_php(language_version)][strate_population] += 1
          strates << strate_population
        end
      end
    end
    application = system[:application] || ''
    if system[:application_version]
      application_version = "#{application} #{system[:application_version]}"
    end
    server = system[:server] || ''
    if system[:server_version]
      server_version = "#{server} #{system[:server_version]}"
    end
  end
  stats_language[language] += 1
  stats_language_version[language_version] += 1
  stats_application[application] += 1
  stats_application_version[application_version] += 1
  stats_server[server] += 1
  stats_server_version[server_version] += 1
end

def print_stats(name, total, hash)
  CSV.open("../resultats/#{name}.csv", 'wb') do |csv|
    hash.to_a.sort { |a, b| b[1] <=> a[1] }.each do |entry|
      percent = ((entry[1].to_f / total.to_f * 10000).to_i).to_f / 100
      csv << ["#{percent}%", entry[0]]
    end
  end
end

p '*** Serveurs'
print_stats('serveurs', total, stats_server)
p ''

p '*** Versions serveur'
print_stats('versions_serveurs', total, stats_server_version)
p ''

p '*** Langages'
print_stats('languages', total, stats_language)
p ''

p '*** Versions langages'
print_stats('versions_langages', total, stats_language_version)
p ''

p '*** Applications'
print_stats('applications', total, stats_application)
p ''

p '*** Versions applications'
print_stats('versions_applications', total, stats_application_version)


php_version_pas_utilisess = Hash.new { |hash, key| hash[key] = Hash.new(0) }

liste_strate = strates.to_a.sort
CSV.open('../resultats/version_php_population.csv', 'wb') do |csv|
  csv << ['Version'] + liste_strate + ['Status', 'Total']

  versions_php.each_pair do |version, strates|
    total = strates.values.inject(:+)
    status = status_php(version)
    if total < 50
      strates.each_pair do |nom_strate, valeur_strate|
        php_version_pas_utilisess[status][nom_strate] += valeur_strate
      end
    else
      csv << [version] + liste_strate.collect { |s| strates[s] } + [status, total]
    end
  end
  php_version_pas_utilisess.each_pair do |status, strates|
    total = strates.values.inject(:+)
    csv << [status] + liste_strate.collect { |s| strates[s] } + [status, total]
  end
end
CSV.open('../resultats/version_php_population_groupe.csv', 'wb') do |csv|
  csv << ['Status'] + liste_strate + ['Total']

  versions_php_groupe.each_pair do |status, strates|
    total = strates.values.inject(:+)
    csv << [status] + liste_strate.collect { |s| strates[s] } + [total]
  end
end
