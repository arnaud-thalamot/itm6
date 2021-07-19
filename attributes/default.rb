########################################################################################################################
#                                                                                                                      #
#                                            Attributes for ITM6 Cookbook                                              #
#                                                                                                                      #
#   Language            : Chef/Ruby                                                                                    #
#   Date                : 01.03.2016                                                                                   #
#   Date Last Update    : 01.03.2016                                                                                   #
#   Version             : 0.4                                                                                          #
#   Author              : Arnaud THALAMOT                                                                              #
#                                                                                                                      #
########################################################################################################################

# ITM6 and Bluecare cookbook execution status
default['itm6']['status'] = 'failure'

# platform choice, either windows or something else
if platform_family?('windows')
  # Processor Architecture (ex : x86_64)
  default['itm6']['arch'] = node['kernel']['machine'].to_s

  # Path to setup file
  default['itm6']['install_Setupfile'] = 'C:\\itm6_temp\\NT_063007000\\setup.exe'

  # ITM directory Path
  default['itm6']['candlehome'] = 'C:\\Program Files\\IBM\\ITM'

  # Path to file to test if ITM agent is installed
  default['itm6']['alreadyInstalledFile'] = 'C:\\Program Files\\IBM\\ITM\\BIN'

  # Configuration directory path
  default['itm6']['configuration_directory'] = 'C:\\Program Files\\IBM\\ITM\\config'
  default['itm6']['configuration_dir_param'] = 'C:\\Program Files\\IBM\\ITM\\smitools\\config'

  # Install path for BlueCare agent
  default['itm6']['bc_install_path'] = ''

  # Installer file for ITM agent
  default['itm6']['ITMfile'] = 'NT_063007000.zip'

  # Remote location for ITM setup file
  default['itm6']['ITMfile_Path'] = 'https://client/ibm/windows2012R2/itm/install_packages/NT_063007000.zip'

  # Remote location for ITM config file
  # default['itm6']['ITMConfig_Path'] = 'https://client/ibm/windows2012R2/itm/default_param/'
  default['itm6']['ITMconfig_EventLog'] = 'https://client/ibm/windows2012R2/itm/default_param/K06_EventLog.param'
  default['itm6']['ITMconfig_LogiDisks'] ='https://client/ibm/windows2012R2/itm/default_param/K06_LogicalDisks.param'
  default['itm6']['ITMconfig_Processes'] ='https://client/ibm/windows2012R2/itm/default_param/K06_Processes.param'
  default['itm6']['ITMconfig_Services'] = 'https://client/ibm/windows2012R2/itm/default_param/K06_Services.param'

  # Installer file for BlueCare agent
  default['itm6']['BCfile'] = '06_030100000.zip'

  # temporary directory to copy installer
  default['itm6']['temp'] = 'C:\\itm6_temp\\'

  # ITM6 Insallation log location
  default['itm6']['InstallLog'] = 'C:\\InstallITMA.log'
  
  # local repository for ITM ifix
  default['itm6']['ifix_temp'] = 'C:\\itm6_temp\\NT_063007000\\iFix\\'

  # attributes to set configuration paratemeters in silent.txt file required for itm6 agent configuration
  default['itm6']['encryption_key'] = 'IBMTivoliMonitoringEncryptionKey'
  default['itm6']['protocol1'] = 'IP.SPIPE'
  default['itm6']['inspipe_port'] = '3660'
  default['itm6']['ipspipe_host'] = '10.0.132.46'
  default['itm6']['fto_flag'] = 'Y'
  default['itm6']['fto_ipspipe_host'] = '10.0.132.47'

  # attributes for activate/deactivate monitoring
  default['itm6']['app'] = 'ICO'
  default['itm6']['activate_req_type'] = 'ADD'
  default['itm6']['deactivate_req_type'] = 'DEL'
  default['itm6']['requestID'] = '1'
  default['itm6']['status'] = 'NEW'
  default['itm6']['data_file_version'] = '1'
  default['itm6']['transactionID'] = '1'
  default['itm6']['request_date_time'] = 'Time.new.strftime("%Y%m%d%H%M%S")'
  default['itm6']['system_hostname'] = ''
  default['itm6']['system_platform'] = ''
  default['itm6']['system_IP_address'] = ''
  default['itm6']['service_responsibility'] = 'CC0 SMI AIX, CC0 SMI LINUX, CC0 SMI WIN'
else
  # Repository of installation packages [this is a TEMPORARY NFS mount located inside CMA network]
  default['itm6']['repository'] = '/opt/IBM/itm_software'
  # preinstall package url list - pulp repository
  default['itm6']['package_url'] = ''
  # preinstall packages
  default['itm6']['package_pkg'] = ['libstdc++.i686', 'compat-libstdc++-33.i686', 'compat-libstdc++-33']
  # ITM pulp repository url
  default['itm6']['itm_url'] = 'https://client/ibm/redhat7/itm/install_packages/lz_063007000_lx8266_Script.tar'
  default['itm6']['prechecker_url'] = 'https://client/ibm/redhat7/itm/prereqchecker/prereqchecker.tar.gz'
  default['itm6']['bc_url'] = 'https://client/ibm/redhat7/itm/install_packages/08_031000000_unix.tar.gz'
  # Name of the logical volume dedicated for ITM, no slash after last directory name
  default['itm6']['logical_volume_name'] = '/opt/IBM'
  # Path to the file used to test if the server is a VIO
  default['itm6']['vio_evidence'] = '/usr/ios/cli/ioscli'
  # Trigram of CMA customer, mandatory
  default['itm6']['trigram'] = 'cc0'
  # Name of silent configuration file used for ITM6 OS agent install
  default['itm6']['silentconfig'] = "/opt/IBM/ITM/silent_config_#{node['itm6']['trigram']}.txt"
  # Path to file to test if ITM agent is installed
  default['itm6']['alreadyInstalledFile'] = '/opt/IBM/ITM/bin/cinfo'
  # Configuration directory path
  default['itm6']['configuration_directory'] = '/opt/IBM/ITM/config'
  # Configuration directory path
  default['itm6']['binaries_url'] = 'https://client/ibm/redhat7/itm/install_packages/'
  # Uninstallation script path
  default['itm6']['uninstall_dir'] = '/opt/IBM/ITM/bin'
  default['itm6']['uninstall_cmd'] = ''
  # Candle Home
  default['itm6']['candlehome'] = '/opt/IBM/ITM/'

  default['itm6']['volumegroup'] = 'ibmvg'
  default['itm6']['logvols'] = [
    {
      'volname' => 'lv_itm_opt',
      'size' => '2G',
      'mountpoint' => '/opt/IBM/ITM',
      'fstype' => 'xfs',
    },
    {
      'volname' => 'lv_itm_logs',
      'size' => '300M',
      'mountpoint' => '/opt/IBM/ITM/logs',
      'fstype' => 'xfs',
    }
  ]
end

# Trigram of CMA customer, mandatory
default['itm6']['trigram'] = 'cc0'
# The version of the targeted ITM6 OS agent
default['itm6']['lastversion'] = '06300700'
# The original hostname of the machine
default['itm6']['hostname'] = node['hostname'].downcase
# Name of ITM6 node that will be used for CTIRA_HOSTNAME and CTIRA_SYSTEM_NAME
# naming convention is CustomerTrigram_servername  ex: cc0_myserver]
default['itm6']['agentname'] = "#{node['itm6']['trigram']}_#{node['itm6']['hostname']}"
# already installed file for bluecare
default['itm6']['alreadyInstalledFileBC'] = '/opt/IBM/ITM/smitools/config/K08_filesystem.param'
# Type of OS (Linux, AIX or other)
default['itm6']['ostype'] = ''
# Processor Architecture (ex : x86_64)
default['itm6']['arch'] = ''
# Last version for ITM agent
default['itm6']['last version'] = ''
# Product code for ITM agent
default['itm6']['product'] = 'lz'
# Product code for BlueCare agent
default['itm6']['bc_product'] = ''
# Last version for BlueCare agent
default['itm6']['bc_lastversion'] = ''
# Version for BlueCare agent
default['itm6']['bc_packageversion'] = ''
# Package for BlueCare agent
default['itm6']['bc_package'] = '08_031000000_unix'
# Install path for BlueCare agent
default['itm6']['bc_install_path'] = (node['itm6']['repository']).to_s + '/' + (node['itm6']['bc_package']).to_s
# Code media ofr naming convention
default['itm6']['media'] = 'lx8266'
# Product code for installed ITM agent
default['itm6']['installedProduct'] = ''
# Version for installed ITM agent
default['itm6']['installedVersion'] = ''
# Product code for installed BlueCare agent
default['itm6']['bc_installed'] = ''
# Version for installed BlueCare agent
default['itm6']['bc_installedversion'] = ''
# Name of Bluecare configuration file
default['itm6']['bc_config_ini'] = ''
# Package code name
default['itm6']['package'] = ''
# Install path for ITM agent
default['itm6']['install_path'] = ''
# Name of ITM6 configuration file
default['itm6']['itm_config_ini'] = ''
# Flag used on filesystem
default['itm6']['flag'] = ''
# attributes for monitoring activation/deactivation - Linux
default['itm6']['app'] = 'ICO'
default['itm6']['activate_req_type'] = 'ADD'
default['itm6']['deactivate_req_type'] = 'DEL'
default['Data_File_Version'] = 1
default['TransactionID'] = ''
default['Request_Date_Time'] = ''
default['Request_Type'] = 'ADD'
default['System_Hostname'] = ''
default['Trigram'] = 'CC0'
default['System_Platform'] = 'LINUX'
default['System_IP_Address'] = ''
default['Service_Responsibility'] = ['CC0 AIX', 'CC0 AIX DEMO', 'CC0 AIX IPSOFT', 'CC0 BTECH WEB - DEV', 'CC0 BTECH WEB - PRD', 'CC0 BTECH WEB - PRE', 'CC0 CSFS PORT', 'CC0 DB', 'CC0 DB Data Guard', 'CC0 GPFS', 'CC0 HPUX', 'CC0 LINUX', 'CC0 LINUX IPSOFT', 'CC0 MIDDLEWARE', 'CC0 MYSAP', 'CC0 OAS', 'CC0 OPS', 'CC0 SMI AIX', 'CC0 SMI LINUX', 'CC0 SMI WIN', 'CC0 TSM', 'CC0 TWS', 'CC0 VIOS', 'CC0 WIN IPSOFT test', 'CC0 WIN OS NON-PROD IPSOFT', 'CC0 WIN OS NON-PRODUCTION', 'CC0 WIN OS PRODUCTION', 'CC0 WIN OS PRODUCTION IPSOFT', 'CMA_WIN_MSSQL', 'MSSQL servers for CMA']
# location for the file
default['target_location'] = '/opt/IBM/'
# local path for file upload
default['local_path'] = '/opt/IBM/'
# remote path for file upload
default['remote_path'] = ''
