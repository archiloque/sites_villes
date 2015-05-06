require 'sequel'

DB = Sequel.connect('postgres://sites_villes:sites_villes@localhost:5432/sites_villes')

SITES = DB[:sites]
HEADERS = DB[:headers]
SYSTEMS = DB[:systems]
HTTPS = DB[:https]
VILLES = DB[:villes]
POPULATIONS = DB[:populations]

class String
  def encode_brutal
    encode('utf-8', {:invalid => :replace, :undef => :replace, :replace => '?'})
  end
end


SUPPORTED_PHP_VERSIONS = ['5.5.22', '5.4.39', '5.4.38', '5.4.37', '5.5.21', '5.6.5', '5.6.6']
UNSUPPORTED_PHP_VERSIONS = [
    '5.6.4', '5.6.3', '5.6.1', '5.6.0',
    '5.5.20', '5.5.19', '5.5.18', '5.5.17', '5.5.16', '5.5.15', '5.5.14', '5.5.13', '5.5.11', '5.5.10', '5.5.8', '5.5.7', '5.5.5', '5.5.4', '5.5.3', '5.5.2', '5.5.1', '5.5.0',
    '5.4.35', '5.4.34', '5.4.33', '5.4.32', '5.4.31', '5.4.30', '5.4.29', '5.4.28', '5.4.27', '5.4.25', '5.4.24', '5.4.23', '5.4.22', '5.4.19', '5.4.18', '5.4.17', '5.4.15', '5.4.14', '5.4.12', '5.4.11', '5.4.10', '5.4.9', '5.4.8', '5.4.7', '5.4.6', '5.4.5', '5.4.4', '5.4.3', '5.4.2', '5.4.1', '5.4.0',
    '5.3.29', '5.3.28', '5.3.27', '5.3.26', '5.3.25', '5.3.24', '5.3.23', '5.3.22', '5.3.21', '5.3.20', '5.3.19', '5.3.18', '5.3.17', '5.3.16', '5.3.15', '5.3.14', '5.3.13', '5.3.12', '5.3.11', '5.3.9', '5.3.8', '5.3.7', '5.3.6', '5.3.5', '5.3.4', '5.3.2', '5.3.1', '5.3.0',
    '5.2.17', '5.2.16', '5.2.15', '5.2.14', '5.2.13', '5.2.12', '5.2.11', '5.2.10', '5.2.9', '5.2.8', '5.2.7', '5.2.6', '5.2.5', '5.2.4', '5.2.3', '5.2.2', '5.2.1', '5.2.0',
    '5.1.5', '5.1.4', '5.1.3', '5.1.2', '5.1.1', '5.1.0',
    '4.4.9', '4.4.8', '4.4.7', '4.4.6', '4.4.5', '4.4.4', '4.4.3', '4.4.2', '4.4.1', '4.4.0',
    '4.3.11', '4.3.10', '4.3.8', '4.3.7', '4.3.6', '4.3.5', '4.3.4', '4.3.3', '4.3.2', '4.3.1', '4.3.0',
    '4.2.3', '4.2.2', '4.2.1', '4.2.0',
    '4.1.2', '4.1.1', '4.1.0',
    '5.0.5', '5.0.4', '5.0.3', '5.0.2', '5.0.1', '5.0.0'
]

UNKNOWN_PHP_VERSIONS = [
    '4.3.9', # RH 4
    '5.1.6', # RH 5
    '5.3.3', # RH 6, Debian 7
    '5.4.16', # RH 7
    '5.4.36', # Debian 6
    '5.3.10', # Ubuntu 12.04
    '5.5.9', # Ubuntu 14.04
    '5.5.12', # Ubuntu 14.09
    '5.5.6', # Fedora 20
    '5.6.2', # Fedora 21
    '5.4.20', # OpenSuse 13.1
    '5.4.21', # OpenSuse 13.2
    '5.4.13', # FreeBSD 8.4
    '5.4.26', # FreeBSD 9.3
    '5.4.23', # FreeBSD 10.1
]

CATEGORY_NO_SITE = 'Pas de site'
CATEGORY_INFO_INSUFFISANTE = 'Niveau de sécurité incertain'
CATEGORY_SITE_PAS_A_JOUR = 'Pas à jour'
CATEGORY_SITE_A_JOUR = 'À jour'
CATEGORY_MASQUE = 'Informations masquées (vulnérabilités pas exposées)'

CATEGORIES_SITES = [CATEGORY_NO_SITE, CATEGORY_INFO_INSUFFISANTE, CATEGORY_SITE_PAS_A_JOUR, CATEGORY_SITE_A_JOUR, CATEGORY_MASQUE]