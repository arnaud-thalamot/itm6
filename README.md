ITM6 Cookbook

The itm6 cookbook verifies the prerequisites for ITM6 agent installation. On successful verification of the prerequisites it will perform silent installation of ITM agent version 6 on the node.
It contains the recipe to perform installation of Bluecare agent v2.3.
It contains the recipe for activation and deactivation of monitoring.
Also It contains the recipe for uninstallation of ITM6 and BlueCare agent.

Requirements

- Storage : 2 GB
- RAM : 2 GB
- Versions
	- Chef Development Kit Version: 0.17.17
	- Chef-client version: 12.13.37
	- Kitchen version: 1.11.1

Platforms

    RHEL-7/Windows 2012

Chef

    Chef 11+

Cookbooks

    none

Resources/Providers

-itm6agent
	This itm6agent resource/provider performs the following :-
	
    1. Creates necessary directories for 
	   - copying the itm6 agent Native installer
	   - copying the input file silent_agent_install.txt for agent configuration
	2. Extracting the itm6 installer to fetch the required setup file for installation
	3. Install the itm v 6 from temporary directory
	4. Delete the temporary directory containing the files used during installation.
	5. uninstall the itm6 agent if uninstall recipe for ITM agent get called.
	
	Example,
	For windows,
	itm6_itm6agent 'install-and-configure-itm6agent' do
      action [:install, :configure]
    end  

	For RHEL,
    itm6_itm6agent 'install-and-configure-itm6agent' do
      action [:preinstall, :install, :configure]
    end

    Actions
      :preinstall - sets the prerequisite for installing ITM by installing base packages and download and copy binaries from pulp repository
      :install - installs the ITM6 agent
      :configure - configures the ITM6 agent
	  
	For uninstalling,
	itm6_itm6agent 'uninstall-itm6agent' do
      action [:uninstall]
    end
	
    Actions
      :uninstall - uninstall the ITM6 agent

- bluecareagent
  This bluecareagent resource/provider performs the following :-

  1. Creates necessary directories for 
	   - copying the bluecare agent Native installer
	2. Extracting the bluecare installer to fetch the required setup file for installation
	3. Install the bluecare v 2.3 from temporary directory
	4. Delete the temporary directory containing the files used during installation.
	5. and uninstall the bluecare agent if uninstall recipe for bluecare agent is get called.

	Example,
    For Windows,
	itm6_bluecareagent 'install-and-configure-bluecareagent' do
      action [:install, :configure]
    end
	
	For RHEL,
	itm6_bluecareagent 'install-and-configure-bluecareagent' do
      action [:preinstall, :install, :configure]
    end

    Actions
      :preinstall - sets the prerequisite for installing ITM by installing base packages and download and copy binaries from pulp repository
      :install - install the bluecare agent
      :configure - configures the ITM6 agent
	  
- monitoring
	This monitoring resource/provider performs the following :-
	
	1. Identifies the file creation based on activation and deactivation of monitoring
	2. Set's filename to Customer_App_Type_Timestamp_Requestid_Status.csv, where all the attributes sets at run time
	3. Generates the file at C:\temp for windows location with required ownership and permissions and copy it on bluecare server.
	

    Example
	itm6_monitoring 'activate-monitoring' do
      action [:activate]
    end
    Actions
      :activate - activate the monitoring

    itm6_monitoring 'deactivate-monitoring' do
      action [:deactivate]
    end
    Actions
      :deactivate - deactivate the monitoring

Attributes

Below attributes for ITM6 agent:
  
  For Linux
  # Repository of installation packages [this is a TEMPORARY NFS mount located inside CMA network]
  default['itm6']['repository'] = '/distribnas/GFS3-Monitoring-ITM6'

  # Name of the logical volume dedicated for ITM, no slash after last directory name
  default['itm6']['logical_volume_name'] = '/opt/IBM'

  # Path to the script to check prerequisites
  default['itm6']['prereq_checker_path'] = "#{node['itm6']['repository']}/prereqchecker/prereq_checker.sh"

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

  # Trigram of CMA customer, mandatory
  default['itm6']['trigram'] = 'CC0'

  # The version of the targeted ITM6 OS agent
  default['itm6']['lastversion'] = '06300400'

  # The original hostname of the machine
  default['itm6']['hostname'] = node['hostname'].downcase

  # Name of ITM6 node that will be used for CTIRA_HOSTNAME and CTIRA_SYSTEM_NAME
  # naming convention is CustomerTrigram_servername  ex: cc0_myserver]
  default['itm6']['agentname'] = "#{node['itm6']['trigram']}_#{node['itm6']['hostname']}"

  # Type of OS (Linux, AIX or other)
  default['itm6']['ostype'] = ''

  # Processor Architecture (ex : x86_64)
  default['itm6']['arch'] = ''

  # Last version for ITM agent
  default['itm6']['last version'] = ''

  # Product code for ITM agent
  default['itm6']['product'] = ''

  # Product code for BlueCare agent
  default['itm6']['bc_product'] = ''

  # Last version for BlueCare agent
  default['itm6']['bc_lastversion'] = ''

  # Version for BlueCare agent
  default['itm6']['bc_packageversion'] = ''

  # Package for BlueCare agent
  default['itm6']['bc_package'] = ''

  # Install path for BlueCare agent
  default['itm6']['bc_install_path'] = ''

  # Code media ofr naming convention
  default['itm6']['media'] = ''

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
  default['target_location'] = '/tmp/'

  # local path for file upload
  default['local_path'] = '/tmp/'

  # remote path for file upload
  default['remote_path'] = ''

  For Windows
  # Path to setup file
  default['itm6']['install_Setupfile'] = 'C:\\itm6_temp\\WINDOWS\\setup.exe'
  
  # ITM directory Path
  default['itm6']['candlehome'] = 'C:\\IBM\\ITM'

  # Path to file to test if ITM agent is installed  
  default['itm6']['alreadyInstalledFile'] = 'C:\\IBM\\ITM\\BIN'

  # Trigram of CMA customer, mandatory
  default['itm6']['trigram'] = 'CC0'

  # Name of silent configuration file used for ITM6 OS agent install
  default['itm6']['silentconfig'] = "C:\\IBM\\ITM\\silent_config_#{node['itm6']['trigram']}.txt"
  
  # Name of the logical volume dedicated for ITM, no slash after last directory name
  default['itm6']['logical_volume_name'] = 'C:\\IBM'
  
  # Configuration directory path
  default['itm6']['configuration_directory'] = 'C:\\IBM\\ITM\\config'
  
  # Installer file for ITM agent
  default['itm6']['ITMfile'] = 'NT_063004000_WINNT.zip'
  
  # Remote location for ITM setup file
  default['itm6']['ITMfile_Path'] = 'https://pulp.cma-cgm.com/ibm/windows2012R2/itm6/NT_063004000_WINNT.zip'
  
  # Installer file for bluecare agent
  default['itm6']['native_bcfile'] = 'K06v230a.zip'
  
  # temporary directory to copy installer
  default['itm6']['temp'] = 'C:\\itm6_temp\\'
  
  # ITM6 Insallation log location
  default['itm6']['InstallLog'] = 'C:\\InstallITMA.log'
  
  # attributes to set configuratioinn paratemeters in silent.txt file required for itm6 agent configuration
  default['itm6']['encryption_key'] = 'IBMTivoliMonitoringEncryptionKey'
  default['itm6']['protocol1'] = 'IP.SPIPE'
  default['itm6']['inspipe_port'] = '3660'
  default['itm6']['ipspipe_host'] = '10.0.132.46'
  default['itm6']['fto_flag'] = 'Y'
  default['itm6']['fto_ipspipe_host'] = '10.0.132.47'
  
  For Windows
  # attributes for activate/deactivate monitoring - Windows
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
