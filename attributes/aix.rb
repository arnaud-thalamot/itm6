########################################################################################################################
#                                                                                                                      #
#                                  ITM6 attribute for ITM6 Cookbook                                                    #
#                                                                                                                      #
#   Language            : Chef/Ruby                                                                                    #
#   Date                : 18.12.2017                                                                                   #
#   Date Last Update    : 31.01.2017                                                                                   #
#   Version             : 0.1                                                                                          #
#   Author              : Arnaud THALAMOT                                                                              #
#                                                                                                                      #
########################################################################################################################

case node['platform']
when 'aix'
# Repository of installation packages [this is a TEMPORARY NFS mount located inside client network]
  default['itm6']['repository'] = '/tmp/itm_software'

  # preinstall package url list - pulp repository
  default['itm6']['package_url'] = ''

  # preinstall packages
  default['itm6']['package_pkg'] = ['libstdc++.i686', 'compat-libstdc++-33.i686', 'compat-libstdc++-33']
  # package_url = ['https://client.com/ibm/redhat7/itm/install_packages/lz_063006000_lx8266.tar.gz', 'https://client.com/ibm/redhat7/itm/prereqchecker/prereqchecker.tar.gz', 'https://client.com/ibm/redhat7/itm/default_param/K08_filesystem.param', 'https://client.com/ibm/redhat7/itm/default_param/K08_process.param' ]

  # ITM pulp repository url
  default['itm6']['itm_url'] = 'http://client.com/ibm/aix7/itm/install_packages/ux_063007001_aix526_Script.tar'
  default['itm6']['prechecker_url'] = 'http://client.com/ibm/aix7/itm/prereqchecker/prereqcheck.tar'
  default['itm6']['bc_url'] = 'http://client.com/ibm/aix7/itm/install_packages/itm/install_packages/'

  # Name of the logical volume dedicated for ITM, no slash after last directory name
  default['itm6']['logical_volume_name'] = '/opt/IBM'

  # Path to the script to check prerequisites
  # default['itm6']['prereq_checker_path'] = "#{node['itm6']['repository']}/prereqchecker/prereq_checker.sh"

  # Path to the file used to test if the server is a VIO
  default['itm6']['vio_evidence'] = '/usr/ios/cli/ioscli'

  # Trigram of client customer, mandatory
  default['itm6']['trigram'] = 'cc0'

  # Name of silent configuration file used for ITM6 OS agent install
  default['itm6']['silentconfig'] = "/opt/IBM/ITM/silent_config_#{node['itm6']['trigram']}.txt"

  # Path to file to test if ITM agent is installed
  default['itm6']['alreadyInstalledFile'] = '/opt/IBM/ITM/bin/cinfo'

  # Configuration directory path
  default['itm6']['configuration_directory'] = '/opt/IBM/ITM/config'

  # Configuration directory path
  default['itm6']['binaries_url'] = 'https://client.com/ibm/aix7/itm/install_packages/'

  # Uninstallation script path
  default['itm6']['uninstall_dir'] = '/opt/IBM/ITM/bin'

  default['itm6']['uninstall_cmd'] = ''

  # product code for AIX
  # Product code for ITM agent
  default['itm6']['product'] = 'ux'

  # Product code for BlueCare agent
  default['itm6']['bc_product'] = ''

  # Last version for BlueCare agent
  default['itm6']['bc_lastversion'] = ''

  # Version for BlueCare agent
  default['itm6']['bc_packageversion'] = ''

  # Package for BlueCare agent
  default['itm6']['bc_package'] = 'ux_063007001_aix526_Orth/K07v310'

  # Install path for BlueCare agent
  default['itm6']['bc_install_path'] = (node['itm6']['repository']).to_s + '/' + (node['itm6']['bc_package']).to_s
  
  # already installed file for bluecare
  default['itm6']['alreadyInstalledFileBC'] = '/opt/IBM/ITM/smitools/config/K07_filesystem.param'

end

