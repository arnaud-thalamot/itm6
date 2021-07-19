########################################################################################################################
#                                                                                                                      #
#                                  ITM6 agent provider for ITM6 Cookbook                                               #
#                                                                                                                      #
#   Language            : Chef/Ruby                                                                                    #
#   Date                : 01.03.2016                                                                                   #
#   Date Last Update    : 01.03.2016                                                                                   #
#   Version             : 0.4                                                                                          #
#   Author              : Arnaud THALAMOT                                                                              #
#                                                                                                                      #
########################################################################################################################

require 'chef/resource'

use_inline_resources

def whyrun_supported?
  true
end

action :preinstall do
  converge_by("Create #{@new_resource}") do
    case node['platform']
    when 'redhat'
      if ::File.exist?((node['itm6']['alreadyInstalledFile']).to_s)
        Chef::Log.info('ITM already installed .... Skipping the preinstallation steps !!')
      else
        preinstall_itm
        preinstall_bc
      end
    when 'aix'
      if ::File.exist?((node['itm6']['alreadyInstalledFile']).to_s)
        Chef::Log.info('ITM already installed .... Skipping the preinstallation steps !!')
      else
        preinstall_itm_aix
        preinstall_bc_aix
      end
    end
  end
end

def preinstall_itm
  Chef::Log.info('Installing C++ prereq packages.........')

  package = ['libstdc++.i686', 'compat-libstdc++-33.i686', 'compat-libstdc++-33']

  # check if the packages are installed on the system
  yum_list = shell_out('yum list installed > /tmp/packagelist.txt 2>&1')

  package.each do |dep|
    yum_package dep do
      action :install
      ignore_failure true
      not_if do
        shell_out("grep #{dep} /tmp/packagelist.txt").stdout != ''
        Chef::Log.info(" #{dep} already installed ....Nothing to do!")
      end
    end
  end

  # create temporary directory for copying ITM6 binaries

  directory node['itm6']['repository'].to_s do
    Chef::Log.info('Creating temp directory........')
    recursive true
    action :create
  end

  Chef::Log.info('Downloading and copying ITM6 packages to temp location......')

  # download prereq_checker for ITM6 to temp location

  node.default['itm6']['prereq_pkg'] = 'prereqchecker.tar.gz'
  node.default['itm6']['itm_pkg'] = 'lz_063007000_lx8266_Script.tar'
  node.default['itm6']['itm_tar'] = 'lz_063007000_lx8266.tar'

  execute 'download-itm-installer' do
    cwd "#{node['itm6']['repository']}"
    command "wget #{node['itm6']['itm_url']} --no-check-certificate"
    action :run
    not_if{ ::File.exist?("#{node['itm6']['repository']}/#{node['itm6']['itm_pkg']}") }
  end

  # extracting the binaries of ITM
  Chef::Log.info('Extracting ITM binaries..........')

  # extract prechecker
  execute 'unpack-itm-binary' do
    command 'cd ' + node['itm6']['repository'].to_s + ' ; ' + ' tar -xf ' + node['itm6']['itm_pkg'].to_s
    action :run
  end

  execute 'download-prereq-checker' do
    cwd "#{node['itm6']['repository']}"
    command "wget #{node['itm6']['prechecker_url']} --no-check-certificate"
    action :run
    not_if{ ::File.exist?("#{node['itm6']['repository']}/#{node['itm6']['prereq_pkg']}") }
  end

  # extract prechecker
  Chef::Log.info('Extracting prereq-checker...............')
  execute 'unpack-prechecker' do
    command 'cd ' + node['itm6']['repository'].to_s + ' ; ' + ' tar -xf ' + node['itm6']['prereq_pkg'].to_s
    action :run
  end
end

# preinstall steps for aix
def preinstall_itm_aix

  # create FS prerequisites for AIX platform
  create_fs

  # create temporary directory for copying ITM6 binaries

  directory "#{node['itm6']['repository']}" do
    Chef::Log.info('Creating temp directory........')
    recursive true
    action :create
  end

  Chef::Log.info('Downloading and copying ITM6 packages to temp location......')

  # download prereq_checker for ITM6 to temp location

  node.default['itm6']['prereq_pkg'] = 'prereqcheck.tar'
  node.default['itm6']['itm_pkg'] = 'ux_063007001_aix526_Script/ux_063006000_aix526/'
  node.default['itm6']['itm_tar'] = 'ux_063007001_aix526_Script.tar'
  
  execute 'download-itm-binary-aix' do
    cwd "#{node['itm6']['repository']}"
    command "wget #{node['itm6']['itm_url']} --no-check-certificate"
	action :run
	not_if { ::File.exists?("#{node['itm6']['repository']}/#{node['itm6']['itm_tar']}") }
  end

  # extracting the binaries of ITM
  Chef::Log.info('Extracting ITM binaries..........')

  # extract itm binary
  execute 'unpack-itm-binary' do
    command 'cd ' + node['itm6']['repository'].to_s + ' ; ' + ' tar -xf ' + node['itm6']['itm_tar'].to_s
    action :run
  end

  execute 'download-prereqchecker-aix' do
    cwd "#{node['itm6']['repository']}"
    command "wget #{node['itm6']['prechecker_url']} --no-check-certificate"
	action :run
	not_if { ::File.exists?("#{node['itm6']['repository']}/#{node['itm6']['prereq_pkg']}") }
  end

  # extract prechecker
  execute 'unpack-prechecker' do
    Chef::Log.info('Extracting prereq-checker...............')
    command 'cd ' + node['itm6']['repository'].to_s + ' ; ' + ' tar -xf ' + node['itm6']['prereq_pkg'].to_s
    ignore_failure true
    action :run
  end
end

# preinstall steps for linux
def preinstall_bc
  # create temporary directory for copying ITM6 binaries

  directory node['itm6']['repository'].to_s do
    Chef::Log.info('Creating temp directory........')
    recursive true
    action :create
    not_if { ::File.exist?(node['itm6']['repository'].to_s) }
  end

  Chef::Log.info('Downloading and copying bluecare binaries.........')

  # download and copy configuraiton files
  config_pkg = ['08_031000000_unix.tar.gz', 'K08_filesystem.param', 'K08_process.param', 'K08_filesystem.conf']
  config_url = ['https://client/ibm/redhat7/itm/install_packages/08_031000000_unix.tar.gz', 'https://client/ibm/redhat7/itm/default_param/K08_filesystem.param', 'https://client/ibm/redhat7/itm/default_param/K08_process.param', 'https://client/ibm/redhat7/itm/default_param/K08_filesystem.conf']

  config_pkg.each do |pkg|
    config_url.each do |url|
      execute 'download-bluecare-files' do
        command "cd #{node['itm6']['repository']}; " + "wget #{url} --no-check-certificate"
        action :run
    not_if{ ::File.exist?("#{pkg}") }
      end
    end
  end

  Chef::Log.info('Extracting bluecare binaries.......')

  # extracting the binary
  execute 'unpack-bluecare' do
    Chef::Log.info('Extracting bluecare binaries...............')
    command 'cd ' + "#{node['itm6']['repository']}" + ' ; ' + ' tar -xf ' + "#{node['itm6']['bc_package']}" + '.tar.gz'
    action :run
  end
end

# preinstall steps for aix
def preinstall_bc_aix
  # create temporary directory for copying ITM6 binaries

  directory node['itm6']['repository'].to_s do
    Chef::Log.info('Creating temp directory........')
    recursive true
    action :create
    not_if { ::File.exist?(node['itm6']['repository'].to_s) }
  end

  Chef::Log.info('Downloading and copying bluecare binaries.........')

  # download and copy configuraiton files
  config_pkg = ['K07_filesystem.param', 'K07_process.param']
  config_url = ['https://client/ibm/aix7/itm/default_param/K07_filesystem.param', 'https://client/ibm/aix7/itm/default_param/K07_process.param']

  config_pkg.each do |pkg|
    config_url.each do |url|
      execute 'download-config-files' do
        command "cd #{node['itm6']['repository']}; " + "wget #{url} --no-check-certificate"
        action :run
    not_if{ ::File.exist?("#{pkg}") }
      end
    end
  end
end

action :install do
  converge_by("Create #{@new_resource}") do
    case node['platform']
    when 'windows'
      if ::File.exist?(node['itm6']['alreadyInstalledFile'].to_s)
        Chef::Log.info('ITM6 agent is already installed, nothing to install')
      else
        # Create temp directory where we copy/create some files
        directory node['itm6']['temp'].to_s do
          action :create
        end

        remote_file node['itm6']['ITMfile_Path'].to_s do
          source  node['itm6']['ITMfile_Path'].to_s
          path "#{node['itm6']['temp']}\\#{node['itm6']['ITMfile']}"
          action :create
        end
        media = "#{node['itm6']['temp']}#{node['itm6']['ITMfile']}"
        Chef::Log.info('-------------------------------')
        
        # Unpack media
        media = "#{node['itm6']['temp']}#{node['itm6']['ITMfile']}"
        ruby_block 'unzip-install-file' do
          block do
            Chef::Log.info('unpacking the package')
            # command = powershell_out("cd #{node['itm6']['temp']} ; tar -xvf #{media}")
            command = powershell_out "Add-Type -assembly \"system.io.compression.filesystem\"; [io.compression.zipfile]::ExtractToDirectory('C:/itm6_temp/NT_063007000.zip', 'C:/itm6_temp')"
            Chef::Log.debug command.to_s
            action :create
          end
        end

        RNumber = rand(0..1).ceil
        if RNumber == 0 then 
          fto_ipspipe_host = '10.0.0.1'
          ipspipe_host = '10.0.0.2'
        else
          fto_ipspipe_host = '10.0.0.3'
          ipspipe_host = '10.0.0.4'
        end
        Chef::Log.info("ipspipe_host= #{ipspipe_host}" )
        Chef::Log.info("fto_ipspipe_host= #{fto_ipspipe_host}" )
        Chef::Log.info ("Machine Arch: #{node['kernel']['machine']}")
        
        if  ((node['kernel']['machine']).to_s == 'x86_64')  
          # create silent install file
          template "#{node['itm6']['temp']}\\silent_agent.txt" do
            source 'windows_itm_silent_install(x64).erb'
          end
        else
          # create silent install file
          template "#{node['itm6']['temp']}\\silent_agent.txt" do
            source 'windows_itm_silent_install.erb'
          end
        end
        # create silent config file
        template "#{node['itm6']['temp']}\\silent_config.txt" do
          source 'windows_itm_silent_config.erb'
          variables(  
            IPSPIPE_Host: "#{fto_ipspipe_host}",
            FTO_IPSPIPE_Host: "#{ipspipe_host}"
          )
        end
        # Installation of ITM 6
        install_itm6
        ibm_itm6_bluecareagent 'install-and-configure-bluecareagent' do
           action [:install, :installifix, :configure]
        end
      end

    when 'redhat'
      if ::File.exist?((node['itm6']['alreadyInstalledFile']).to_s)
        node.default['itm6']['installedProduct'] = `#{node['itm6']['alreadyInstalledFile']} -b | grep #{node['itm6']['product']}`.chop
        node.default['itm6']['installedVersion'] = `echo #{node['itm6']['installedProduct']} | cut -f4 -d',' | sed 's/"//g'`.chop
        Chef::Log.debug("node['itm6']['installedProduct'] = #{node['itm6']['installedProduct']}")
        Chef::Log.debug("node['itm6']['installedVersion'] = #{node['itm6']['installedVersion']}")
        if node['itm6']['installedProduct']
          Chef::Log.info("Automatic install of #{node['itm6']['product']} ITM6 agent for #{node['itm6']['arch']}")
          if node['itm6']['installedProduct'] > node['itm6']['last version']
            Chef::Log.info("ITM6 agent #{node['itm6']['product']} is installed at the last version, nothing to install")
            install_sv = shell_out("/opt/IBM/ITM/bin/cinfo -r").stdout
            Chef::Log.info("Installation Status and Version :" + install_sv.to_s)
          else
            Chef::Log.info("ITM6 does not use the last version, performing ITM6 update to #{node['itm6']['last version']} if prereqs are ok")
            install_itm6
          end
        else
          install_itm6
        end
      else
        Chef::Log.info("ITM6 product #{node['itm6']['product']} not installed........Installing ITM6")
        install_itm6
      end

    when 'aix'
	  if ::File.exist?((node['itm6']['alreadyInstalledFile']).to_s)
        node.default['itm6']['installedProduct'] = `#{node['itm6']['alreadyInstalledFile']} -b | grep #{node['itm6']['product']}`.chop
        node.default['itm6']['installedVersion'] = `echo #{node['itm6']['installedProduct']} | cut -f4 -d',' | sed 's/"//g'`.chop
        Chef::Log.debug("node['itm6']['installedProduct'] = #{node['itm6']['installedProduct']}")
        Chef::Log.debug("node['itm6']['installedVersion'] = #{node['itm6']['installedVersion']}")
        if node['itm6']['installedProduct']
          Chef::Log.info("Automatic install of #{node['itm6']['product']} ITM6 agent for #{node['itm6']['arch']}")
          if node['itm6']['installedProduct'] > node['itm6']['last version']
            Chef::Log.info("ITM6 agent #{node['itm6']['product']} is installed at the last version, nothing to install")
            install_sv = shell_out("/opt/IBM/ITM/bin/cinfo -r").stdout
            Chef::Log.info("Installation Status and Version :" + install_sv.to_s)
          else
            Chef::Log.info("ITM6 does not use the last version, performing ITM6 update to #{node['itm6']['last version']} if prereqs are ok")
            install_itm6_aix
          end
        else
          install_itm6_aix
        end
      else
        Chef::Log.info("ITM6 product #{node['itm6']['product']} not installed........Installing ITM6")
        install_itm6_aix
      end
    end
  end
end

# installing itm on linux
def install_itm6
  case node['platform']
  when 'windows'
    Chef::Log.info('Performing ITM6 installation...')
    execute 'Install_ITMA' do
      command 'start /wait C:\\itm6_temp\NT_063007000\\setup.exe /w /z" /sfC:\\itm6_temp\\silent_agent.txt" /s /f2"C:\\InstallITMA.log" -PassThru'
      action :run
    end
  when 'redhat'
    
    node['itm6']['logvols'].each do |logvol|
      lvm_logical_volume logvol['volname'] do
        group   node['itm6']['volumegroup']
        size    logvol['size']
        filesystem    logvol['fstype']
        mount_point   logvol['mountpoint']
      end
    end 

    # node.default['itm6']['package'] = (node['itm6']['product']).to_s + '_' + (node['itm6']['lastversion']).to_s + '0_' + (node['itm6']['media']).to_s
    node.default['itm6']['package'] = 'lz_063007000_lx8266_Orth/lz_063007000_lx8266'
    node.default['itm6']['install_path'] = (node['itm6']['repository']).to_s + '/' + (node['itm6']['package']).to_s

    # running the prereq checker to validate if system meets requirements
    check_prereq

    Chef::Log.info('Performing ITM6 installation...')

    execute 'install-itm6' do
      command "#{node['itm6']['install_path']}/silentInstall.sh"
      action :run
    end
    Chef::Log.info('COMPLETE ITM6 installation...')
  end
end

# installing itm on aix
def install_itm6_aix
  case node['platform']
  when 'aix'
    # Check that /opt/IBM/ITM is a dedicated FS
    fs_exists = `df -Pk | grep #{node['itm6']['logical_volume_name']} | wc -l`.chop
    Chef::Log.debug("fs_exists = #{fs_exists}")

    if fs_exists == '0'
      Chef::Log.error("ERROR No dedicated #{node['itm6']['logical_volume_name']} file system exists")
    end

    # node.default['itm6']['package'] = (node['itm6']['product']).to_s + '_' + (node['itm6']['lastversion']).to_s + '0_' + (node['itm6']['media']).to_s
    node.default['itm6']['package'] = 'ux_063007001_aix526_Orth/ux_063007001_aix526'
    node.default['itm6']['install_path'] = (node['itm6']['repository']).to_s + '/' + (node['itm6']['package']).to_s

    # running the prereq checker to validate if system meets requirements
    check_prereq

    Chef::Log.info('Performing ITM6 installation...')

    execute 'install-itm6' do
      command "#{node['itm6']['install_path']}/silentInstall.sh"
      action :run
    end
    Chef::Log.info('COMPLETE ITM6 installation...')
  end
end

action :configure do
  converge_by("Create #{@new_resource}") do
    case node['platform']
    when 'redhat'
      if ::File.exist?((node['itm6']['alreadyInstalledFile']).to_s) 
        node.default['itm6']['itm_config_ini'] = "#{node['itm6']['configuration_directory']}/#{node['itm6']['product']}.ini"
        replace_system_name = `cat #{node['itm6']['itm_config_ini']} | sed 's/^CTIRA_SYSTEM_NAME=.*/CTIRA_SYSTEM_NAME='#{node['itm6']['agentname']}'/g' > #{node['itm6']['itm_config_ini']}.tmp`
        replace_hostname = `cat #{node['itm6']['itm_config_ini']}.tmp | sed 's/^CTIRA_HOSTNAME=.*/CTIRA_HOSTNAME='#{node['itm6']['agentname']}'/g' > #{node['itm6']['itm_config_ini']}`

		# updating the config file for itm
		Chef::Log.info('Setting configuration file .................')
        line_edit = ['CTIRA_SUBSYSTEM_ID=', 'CTIRA_RECONNECT_WAIT=180', 'CTIRA_PRIMARY_FALLBACK_INTERVAL=900', 'KDEB_INTERFACELIST_IPV6=-', 'KDC_FAMILIES=$NETWORKPROTOCOL$ EPHEMERAL:Y HTTP_CONSOLE:N HTTP_SERVER:N HTTP:0 ip use:n ip.pipe use:n sna use:n' ]
        
        line_edit.each do |line|
          execute 'edit ini file' do
            command "echo #{line} >> #{node['itm6']['itm_config_ini']}"
            action :run
            not_if{ shell_out("grep #{line} #{node['itm6']['itm_config_ini']}").stdout !='' }
          end
		    end

        unless ::File.exist?((node['itm6']['silentconfig']).to_s)
          node.default['itm6']['flag'] = "#{node['itm6']['repository']}/flag_#{node['itm6']['product']}"
          if ::File.exist?((node['itm6']['flag']).to_s)
            Chef::Log.info("INFO Flag #{node['itm6']['flag']} exists, removing it")
            remove_flag = `rm -f #{node['itm6']['flag']}`
            template node['itm6']['silentconfig'] do
              source 'silent_config.erb'
              owner 'root'
              group 'root'
              mode '0644'
              variables(
                hostname: '10.0.0.1',
                mirror: '10.0.0.2'
              )
            end
          else
            Chef::Log.info("INFO Flag #{node['itm6']['flag']} does not exists, creating it")
            create_flag = `touch #{node['itm6']['flag']}`
            template node['itm6']['silentconfig'] do
              source 'silent_config.erb'
              owner 'root'
              group 'root'
              mode '0644'
              variables(
                hostname: '10.0.0.3',
                mirror: '10.0.0.4'
              )
            end
          end
        end

        # itm6_service_stop = `/opt/IBM/ITM/bin/itmcmd agent stop #{node['itm6']['product']}`
        execute 'stop-lz-agent' do
          command "/opt/IBM/ITM/bin/itmcmd agent stop #{node['itm6']['product']}"
          action :run
          ignore_failure true
        end

        # configure_itm6 = `/opt/IBM/ITM/bin/itmcmd config -A -p #{node['itm6']['silentconfig']} #{node['itm6']['product']}`
        execute 'configure-lz-agent' do
          command "/opt/IBM/ITM/bin/itmcmd config -A -p #{node['itm6']['silentconfig']} #{node['itm6']['product']}"
          action :run
        end

        Chef::Log.info('COMPLETE ITM6 silent configuration done')

        # itm6_service_start = `/opt/IBM/ITM/bin/itmcmd agent start #{node['itm6']['product']}`
		execute 'start-lz-agent' do
          command "/opt/IBM/ITM/bin/itmcmd agent start #{node['itm6']['product']}"
          action :run
          ignore_failure true
        end

		execute 'set-CANDLEHOME_permission' do
          command "chmod -R o-w #{node['itm6']['candlehome']}"
		  action :run
        end
        # what to do if silentconfig exists ? Reconfigure ? Nothing ?
      else
        Chef::Log.error('ITM6 must be installed to be able to be configured')
      end

    when 'aix'
      if ::File.exist?((node['itm6']['alreadyInstalledFile']).to_s)
        node.default['itm6']['itm_config_ini'] = (node['itm6']['configuration_directory']).to_s + '/' + "#{node['itm6']['product']}.ini"
        replace_system_name = `cat #{node['itm6']['itm_config_ini']} | sed 's/^CTIRA_SYSTEM_NAME=.*/CTIRA_SYSTEM_NAME='#{node['itm6']['agentname']}'/g' > #{node['itm6']['itm_config_ini']}.tmp`
        replace_hostname = `cat #{node['itm6']['itm_config_ini']}.tmp | sed 's/^CTIRA_HOSTNAME=.*/CTIRA_HOSTNAME='#{node['itm6']['agentname']}'/g' > #{node['itm6']['itm_config_ini']}`

		# updating the config file for itm
		Chef::Log.info('Setting configuration file .................')
        line_edit = ['CTIRA_SUBSYSTEM_ID=', 'CTIRA_RECONNECT_WAIT=180', 'CTIRA_PRIMARY_FALLBACK_INTERVAL=900', 'KDEB_INTERFACELIST_IPV6=-', 'KDC_FAMILIES=$NETWORKPROTOCOL$ EPHEMERAL:Y HTTP_CONSOLE:N HTTP_SERVER:N HTTP:0 ip use:n ip.pipe use:n sna use:n' ]
        line_edit.each do |line|
          execute 'edit ini file' do
            command "echo #{line} >> #{node['itm6']['itm_config_ini']}"
            action :run
            not_if{ shell_out("grep #{line} #{node['itm6']['itm_config_ini']}").stdout != '' }
          end
		end

        unless ::File.exist?((node['itm6']['silentconfig']).to_s)
          node.default['itm6']['flag'] = "#{node['itm6']['repository']}/flag_#{node['itm6']['product']}"
          if ::File.exist?((node['itm6']['flag']).to_s)
            Chef::Log.info("INFO Flag #{node['itm6']['flag']} exists, removing it")
            remove_flag = `rm -f #{node['itm6']['flag']}`
            template node['itm6']['silentconfig'] do
              source 'silent_config.erb'
              owner 'root'
              mode '0644'
              variables(
                hostname: '10.0.0.1',
                mirror: '10.0.0.2'
              )
            end
          else
            Chef::Log.info("INFO Flag #{node['itm6']['flag']} does not exists, creating it")
            create_flag = `touch #{node['itm6']['flag']}`
            template node['itm6']['silentconfig'] do
              source 'silent_config.erb'
              owner 'root'
              mode '0644'
              variables(
                hostname: '10.0.0.3',
                mirror: '10.0.0.4'
              )
            end
          end
        end
        configure_itm6 = `/opt/IBM/ITM/bin/itmcmd config -A -p #{node['itm6']['silentconfig']} #{node['itm6']['product']}`
        Chef::Log.info('COMPLETE ITM6 silent configuration done')
        itm6_service_stop = `/opt/IBM/ITM/bin/itmcmd agent stop #{node['itm6']['product']}`
        itm6_service_start = `/opt/IBM/ITM/bin/itmcmd agent start #{node['itm6']['product']}`
        # what to do if silentconfig exists ? Reconfigure ? Nothing ?
      else
        Chef::Log.error('ITM6 must be installed to be able to be configured')
      end
    end
  end
end

def check_prereq
  Chef::Log.info('INFO Running prereq checker')

  # removing old result generated from prereq scanner
  rm_result = `rm -f /result.txt`

  prereq_product = 'K' + (node['itm6']['product']).to_s.upcase
  result_path = '/result.txt'

  node.set['itm6']['prereq_checker_path'] = node['itm6']['repository'].to_s + '/prereqchecker/prereq_checker.sh'
  Chef::Log.info("Prereq_Checker found at : #{node['itm6']['prereq_checker_path']}")
  if ::File.exist?((node['itm6']['prereq_checker_path']).to_s)
    Chef::Log.info('Running Prechecker...........')

    check_prereq = shell_out("#{node['itm6']['prereq_checker_path']} #{prereq_product} #{node['itm6']['last version']} detail")

    if ::File.exist?(result_path.to_s)
      result = ::File.readlines(result_path).grep('overall result:')
      Chef::Log.info("Prereq_checker #{result}")
      status = result.to_s.split[2]
      if status != 'PASS'
        Chef::Log.warn("WARNING : Prereq checker failed, installation at #{node['itm6']['lastversion']} is NOT recommended. Check /prereq.log for more information")
      else
        Chef::Log.info('INFO Installation is possible')
      end
    else
      Chef::Log.error('ERROR Prereq_checker does not run')
    end
  else
    Chef::Log.warn('Prereqchecker does not exist.......')
    check_prereq
  end
end

action :uninstall do
  converge_by("Create #{@new_resource}") do
    case node['platform']
    when 'windows'
      if ::File.exist?(node['itm6']['alreadyInstalledFile'].to_s)
        # Create temp directory where we copy/create some files
        directory node['itm6']['temp'].to_s do
          action :create
        end

        remote_file node['itm6']['ITMfile_Path'].to_s do
          source node['itm6']['ITMfile_Path'].to_s
          path "#{node['itm6']['temp']}\\#{node['itm6']['ITMfile']}"
          action :create
        end

        media = "#{node['itm6']['temp']}#{node['itm6']['ITMfile']}"
        Chef::Log.info('-------------------------------')

        # create response file
        template "#{node['itm6']['temp']}\\silent_agent.txt" do
          source 'silent_agent_uninstall.txt.erb'
        end
        # UnInstallation of ITM 6
        uninstall_itm6
      else
        Chef::Log.info('ITM6 agent is not installed, nothing to uninstall for ITM agent')
      end

    when 'redhat'
      if ::File.exist?((node['itm6']['alreadyInstalledFile']).to_s)
        node.default['itm6']['uninstall_cmd'] = (node['itm6']['uninstall_dir']).to_s + '/' + 'uninstall.sh'

        execute 'uninstalling-itm6' do
          command node['itm6']['uninstall_cmd'].to_s
          action :run
          returns [0, 1]
        end
      else
        Chef::Log.error('ITM6 not installed......Skipping uninstallation')
      end

    when 'aix'
      if ::File.exist?((node['itm6']['alreadyInstalledFile']).to_s)
        node.default['itm6']['uninstall_cmd'] = (node['itm6']['uninstall_dir']).to_s + '/' + 'uninstall.sh'

        execute 'uninstalling-itm6' do
          command node['itm6']['uninstall_cmd'].to_s
          action :run
          returns [0, 1]
        end
      else
        Chef::Log.error('ITM6 not installed......Skipping uninstallation')
      end
    end
  end
end

# create_fs for aix
def create_fs
  Chef::Log.info('Creating File System ...................')

  # creating prerequisite FS
  # create volume group ibmvg as mandatory requirement
  execute 'create-VG-ibmvg' do
    command 'mkvg -f -y ibmvg hdisk1'
    action :run
    returns [0, 1]
    not_if { shell_out('lsvg | grep ibmvg').stdout.chop != '' }
  end
  # required FS
  volumes = [
    { lvname: 'lv_itm_opt', fstype: 'jfs2', vgname: 'ibmvg', size: 2048, fsname: '/opt/IBM/ITM' },
    { lvname: 'lv_itm_logss', fstype: 'jfs2', vgname: 'ibmvg', size: 300, fsname: '/opt/IBM/ITM/logs' }
  ]
  # Custom FS creation
  volumes.each do |data|
    ibm_itm6_makefs "creation of #{data[:fsname]} file system" do
      lvname data[:lvname]
      fsname data[:fsname]
      vgname data[:vgname]
      fstype data[:fstype]
      size data[:size]
    end
  end
end

def uninstall_itm6
  case node['platform']
  when 'windows'
    media = "#{node['itm6']['temp']}#{node['itm6']['ITMfile']}"
    ruby_block 'unzip-install-file' do
      block do
        Chef::Log.info('unpacking the package')
        command = powershell_out("cd #{node['itm6']['temp']} ; tar -xvf #{media}")
        Chef::Log.info(command.stdout)
        action :create
      end
    end
    Chef::Log.info('Performing ITM6 uninstallation...')
    execute 'UnInstall_ITMA' do
      command 'start /wait C:\\itm6_temp\\NT_063007000\\setup.exe /z" /sfC:\\itm6_temp\\silent_agent.txt" /s /f2"C:\\UnInstallITMA.log"'
      action :run
    end    #  Deleting the Temp file
    directory node['itm6']['temp'].to_s do
      recursive true
      action :delete
    end
  end
end
