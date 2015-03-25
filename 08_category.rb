# Calcule la categorie de chaque site

require_relative 'common'
require 'set'

VILLES = DB[:villes]
SITES = DB[:sites]
SYSTEMS = DB[:systems]

MESSAGES = Set.new

SUPPORTED_APACHE_VERSIONS = ['2.2.29']
UNSUPPORTED_APACHE_VERSIONS = ['1.3', '2.0']
UNKNOWN_APACHE_VERSIONS = ['2.2', '2.4']

# CVE-2013-2028 Stack-based buffer overflow with specially crafted request Not vulnerable: 1.5.0+, 1.4.1+ Vulnerable: 1.3.9-1.4.0
# CVE-2012-1180 Memory disclosure with specially crafted backend responses Not vulnerable: 1.1.17+, 1.0.14+ Vulnerable: 0.1.0-1.1.16
# CVE-2009-2629 Buffer underflow vulnerability Not vulnerable: 0.8.15+, 0.7.62+, 0.6.39+, 0.5.38+ Vulnerable: 0.1.0-0.8.14
# CVE-2009-3896 Null pointer dereference vulnerability Not vulnerable: 0.8.14+, 0.7.62+, 0.6.39+, 0.5.38+ Vulnerable: 0.1.0-0.8.13

SUPPORTED_NGINX_VERSIONS = [
	'1.7.10', # from the website
	'1.6.2',
    '1.4.7',
    '1.2.9',
	'1.0.15',
	'0.8.55',
	'0.7.69',

	# no issue
	'1.2.1', # also debian
	'1.6.1',

    '1.7.9', '1.7.8', '1.7.7', '1.7.6', '1.7.5', '1.7.4', '1.7.3', '1.7.2', '1.7.1', '1.7.0',
    '1.6.1', '1.6.0',
    '1.5.12',
    '1.5.11',
    '1.4.6', '1.4.5', '1.4.4', '1.4.3', '1.4.2', '1.4.1', '1.4.0', # CVE-2014-0133
    '1.1.19', '1.1.18', '1.1.17',
]

UNSUPPORTED_NGINX_VERSIONS = [
	# CVE-2012-1180
    '1.1.16', '1.1.15', '1.1.14', '1.1.13', '1.1.12', '1.1.11', '1.1.10', '1.1.9', '1.1.8', '1.1.7', '1.1.6', '1.1.5', '1.1.4', '1.1.3', '1.1.2', '1.1.1', '1.1.0',
    '1.0.14', '1.0.13', '1.0.12', '1.0.11', '1.0.10', '1.0.9', '1.0.8', '1.0.7', '1.0.6', '1.0.5', '1.0.4', '1.0.3', '1.0.2', '1.0.1', '1.0.0',

	# CVE-2009-3896 
    '0.7.66', '0.7.65', '0.7.64', '0.7.63', '0.7.62', '0.7.61', '0.7.60', '0.7.59', '0.7.58', '0.7.57', '0.7.56', '0.7.55', '0.7.54', '0.7.53', '0.7.52', '0.7.51', '0.7.50', '0.7.49', '0.7.48', '0.7.47', '0.7.46', '0.7.45', '0.7.44', '0.7.43', '0.7.42', '0.7.41', '0.7.40', '0.7.39', '0.7.38', '0.7.37', '0.7.36', '0.7.35', '0.7.34', '0.7.33', '0.7.32', '0.7.31', '0.7.30', '0.7.29', '0.7.28', '0.7.27', '0.7.26', '0.7.25', '0.7.24', '0.7.23', '0.7.22', '0.7.21', '0.7.20', '0.7.19', '0.7.18', '0.7.17', '0.7.16', '0.7.15', '0.7.14', '0.7.13', '0.7.12', '0.7.11', '0.7.10', '0.7.9', '0.7.8', '0.7.7', '0.7.6', '0.7.5', '0.7.4', '0.7.3', '0.7.2', '0.7.1', '0.7.0',
    '0.6.35', '0.6.34', '0.6.33', '0.6.32', '0.6.31', '0.6.30', '0.6.29', '0.6.28', '0.6.27', '0.6.26', '0.6.25', '0.6.24', '0.6.23', '0.6.22', '0.6.21', '0.6.20', '0.6.19', '0.6.18', '0.6.17', '0.6.16', '0.6.15', '0.6.14', '0.6.13', '0.6.12', '0.6.11', '0.6.10', '0.6.9', '0.6.8', '0.6.7', '0.6.6', '0.6.5', '0.6.4', '0.6.3', '0.6.2', '0.6.1', '0.6.0',
    '0.5.33', '0.5.32', '0.5.31', '0.5.30', '0.5.29', '0.5.28', '0.5.27', '0.5.26', '0.5.25', '0.5.24', '0.5.23', '0.5.22', '0.5.21', '0.5.20', '0.5.19', '0.5.18', '0.5.17', '0.5.16', '0.5.15', '0.5.14', '0.5.13', '0.5.12', '0.5.11', '0.5.10', '0.5.9', '0.5.8', '0.5.7', '0.5.6', '0.5.5', '0.5.4', '0.5.3', '0.5.2', '0.5.1', '0.5.0',

]
UNKNOWN_NGINX_VERSIONS = [
	'0.7.67' # debian
]

SUPPORTED_IIS_VERSIONS = ['7', '7.0', '7.5', '8.0', '8.5', '6.0']
UNSUPPORTED_IIS_VERSIONS = ['5.0', '4.0']

SUPPORTED_LIGHTTP_VERSIONS = ['1.4.35']
UNKNOWN_LIGHTTP_VERSIONS = ['1.4.28']

IGNORED_SERVERS = ['o2switch', 'LiteSpeed', 'Lotus-Domino', 'SiteW', 'Wix', 'Google', 'Icodia', 'WMaker', 'Tengine', '']

JOOMLA_SUPPORTED_VERSIONS = ['3.3', '3.4']
JOOMLA_UNSUPPORTED_VERSIONS = ['1.5', '1.7', '1.6']

SPIP_SUPPORTED_VERSIONS = [
    '3.0.18-dev', '3.0.17', '3.0.16', '3.0.15', '3.0.14', '3.0.13', '3.0.12', '3.0.11', '3.0.10', '3.0.9',
    '2.1.26', '2.1.25', '2.1.24', '2.1.23', '2.1.22',
    '2.0.25', '2.0.24', '2.0.23',
]
SPIP_UNSUPPORTED_VERSIONS = [
    '3.0.8', '3.0.7', '3.0.6', '3.0.5', '3.0.4', '3.0.3', '3.0.2', '3.0.1', '3.0.0',
    '2.1.21', '2.1.20', '2.1.19', '2.1.18', '2.1.17', '2.1.16', '2.1.15', '2.1.14', '2.1.13', '2.1.12', '2.1.11', '2.1.10', '2.1.9', '2.1.8', '2.1.7', '2.1.6', '2.1.5', '2.1.4', '2.1.3', '2.1.2', '2.1.1', '2.1.0', '2.0.22', '2.0.21', '2.0.20', '2.0.19', '2.0.18', '2.0.17', '2.0.16', '2.0.15', '2.0.14', '2.0.13', '2.0.12', '2.0.11', '2.0.10', '2.0.9', '2.0.8', '2.0.7', '2.0.6', '2.0.5', '2.0.4', '2.0.3', '2.0.2', '2.0.1', '2.0.0',
    '1.9', '1.9.2m', '1.9.2g', '1.9.2i', '1.9.2', '1.9.2d', '1.9.2c', '1.9.1', '1.9.2b', '1.9.2h', '1.9.2p', '1.9.2n', '1.9.2e', '1.9.2a', '1.9.2k', '1.9.2f', '1.9.2o', '1.9.2j',
    '1.8.2 d', '1.8.3', '1-8-2pr2', '1-8-1', '1.8.2 e', '1.8.3b', '1-8-2', '1.8.2 g'
]

WORDPRESS_SUPPORTED_VERSIONS = ['4.0.1', '4.1', '4.1.1']
WORDPRESS_UNSUPPORTED_VERSIONS = [
    '4.0',
    '3.9.3', '3.9.2', '3.9.1', '3.9',
    '3.8.5', '3.8.4', '3.8.3', '3.8.2', '3.8.1', '3.8',
    '3.7.5', '3.7.4', '3.7.3', '3.7.2', '3.7.1', '3.7',
    '3.6.1', '3.6',
    '3.5.1', '3.5',
    '3.5.2', '3.3.1', '3.1',
    '3.4.2', '3.4.1', '3.4',
    '3.3.2', '3.3.1', '3.3',
    '3.2.1',
    '3.1.4', '3.1.3', '3.1.2', '3.1.1', '3.1',
    '3.0.5', '3.0.4', '3.0.3', '3.0.2', '3.0.1', '3.1', '3.0',
    '2.7.1',
    '2.8.6', '2.8.5', '2.8.4', '2.8.3', '2.8.2', '2.8.1', '2.8',
    '2.9.2', '2.9.1', '2.9',
    '2.6.5', '2.6.4', '2.6.3', '2.6.2', '2.6.1', '2.6',
    '2.5.1',
    '2.0.3',
]

TYPO3_SUPPORTED_VERSIONS = []
TYPO3_UNSUPPORTED_VERSIONS = [
    '6.0', '6.1',
    '4.7', '4.6', '4.4', '4.3', '4.2', '4.1', '4.0',
    '6.0',
]
TYPO3_UNKNOWN_VERSIONS = ['6.2', '4.5']

APPLICATIONS_IGNOREES = ['IziSpot', 'Drupal']

STDOUT << "\n\n"

def add_message(message)
  unless MESSAGES.include? message
    STDOUT << "#{message}\n"
    MESSAGES << message
  end
  if MESSAGES.length > 10
    STDOUT << "\n\n"
    exit -1
  end
end

DB[:villes].each do |ville|
  category = CATEGORY_NO_SITE
  if site = SITES.where('ville_id = ? and code = ?', ville[:id], 200).first
    category = CATEGORY_MASQUE
    if (system = SYSTEMS.where('ville_id = ?', ville[:id]).first)
      language = system[:language] || ''
      language_version = system[:language_version] || ''
      if (language != '') && (language_version != '')
        category = CATEGORY_INFO_INSUFFISANTE
        if language == 'php'
          if SUPPORTED_PHP_VERSIONS.include? language_version
            category = CATEGORY_SITE_A_JOUR
          elsif UNSUPPORTED_PHP_VERSIONS.include? language_version
            category = CATEGORY_SITE_PAS_A_JOUR
          elsif !UNKNOWN_PHP_VERSIONS.include?(language_version)
            add_message "Version php inconnue [#{language_version}]"
          end
        else
          add_message "Language inconnu [#{language}]"
        end
      end

      server = system[:server] || ''
      server_version = system[:server_version] || ''
      if (server != '') && (server_version != '')
        if category == CATEGORY_MASQUE
          category = CATEGORY_INFO_INSUFFISANTE
        end
        if server == 'Apache'
          if SUPPORTED_APACHE_VERSIONS.include? server_version
          elsif UNSUPPORTED_APACHE_VERSIONS.include? server_version
            category = CATEGORY_SITE_PAS_A_JOUR
          elsif UNKNOWN_APACHE_VERSIONS.include? server_version
          else
            add_message "Version Apache inconnue [#{server_version}]"
          end
        elsif server == 'Nginx'
          if SUPPORTED_NGINX_VERSIONS.include? server_version
          elsif UNSUPPORTED_NGINX_VERSIONS.include? server_version
            category = CATEGORY_SITE_PAS_A_JOUR
          elsif UNKNOWN_NGINX_VERSIONS.include? server_version
          else
            add_message "Version Nginx inconnue [#{server_version}]"
          end
        elsif server == 'IIS'
          if SUPPORTED_IIS_VERSIONS.include? server_version
          elsif UNSUPPORTED_IIS_VERSIONS.include? server_version
            category = CATEGORY_SITE_PAS_A_JOUR
          else
            add_message "Version IIS inconnue [#{server_version}]"
          end
        elsif server == 'Lighttp'
          if SUPPORTED_LIGHTTP_VERSIONS.include? server_version
          elsif UNKNOWN_LIGHTTP_VERSIONS.include? server_version
            category = CATEGORY_SITE_PAS_A_JOUR
          else
            add_message "Version Lighttp inconnue [#{server_version}]"
          end
        elsif !IGNORED_SERVERS.include? server
          add_message "Serveur inconnu [#{server}]"
        end
      end

      application = system[:application] || ''
      application_version = system[:application_version] || ''

      if (application != '') && (application_version != '')
        if application == 'Joomla'
          if category == CATEGORY_MASQUE
            category = CATEGORY_INFO_INSUFFISANTE
          end
          if JOOMLA_SUPPORTED_VERSIONS.include? application_version
            if category != CATEGORY_SITE_PAS_A_JOUR
              category = CATEGORY_SITE_A_JOUR
            end
          elsif JOOMLA_UNSUPPORTED_VERSIONS.include? application_version
            category = CATEGORY_SITE_PAS_A_JOUR
          else
            add_message "Version Joomla inconnue [#{application_version}]"
          end
        elsif application == 'SPIP'
          if category == CATEGORY_MASQUE
            category = CATEGORY_INFO_INSUFFISANTE
          end
          if SPIP_SUPPORTED_VERSIONS.include? application_version
            if category != CATEGORY_SITE_PAS_A_JOUR
              category = CATEGORY_SITE_A_JOUR
            end
          elsif SPIP_UNSUPPORTED_VERSIONS.include? application_version
            category = CATEGORY_SITE_PAS_A_JOUR
          else
            add_message "Version Spip inconnue [#{application_version}]"
          end
        elsif application == 'WordPress'
          if category == CATEGORY_MASQUE
            category = CATEGORY_INFO_INSUFFISANTE
          end
          if WORDPRESS_SUPPORTED_VERSIONS.include? application_version
            if category != CATEGORY_SITE_PAS_A_JOUR
              category = CATEGORY_SITE_A_JOUR
            end
          elsif WORDPRESS_UNSUPPORTED_VERSIONS.include? application_version
            category = CATEGORY_SITE_PAS_A_JOUR
          else
            add_message "Version Wordpress inconnue [#{application_version}]"
          end
        elsif application == 'TYPO3'
          if category == CATEGORY_MASQUE
            category = CATEGORY_INFO_INSUFFISANTE
          end
          if TYPO3_SUPPORTED_VERSIONS.include? application_version
            if category != CATEGORY_SITE_PAS_A_JOUR
              category = CATEGORY_SITE_A_JOUR
            end
          elsif TYPO3_UNSUPPORTED_VERSIONS.include? application_version
            category = CATEGORY_SITE_PAS_A_JOUR
          elsif TYPO3_UNKNOWN_VERSIONS.include? application_version
          else
            add_message "Version TYPO3 inconnue [#{application_version}]"
          end
        elsif application == 'Drupal'
          if application_version != '7'
            add_message "Version drupal inconnue [#{application_version}]"
          end
        elsif !APPLICATIONS_IGNOREES.include?(application)
          add_message "Application inconnue [#{application}]"
        end
      end
    end

  end


  if ville[:category] != category
    VILLES.where("id = ?", ville[:id]).update({:category => category})
  end

end

