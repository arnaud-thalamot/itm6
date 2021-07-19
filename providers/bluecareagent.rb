########################################################################################################################
#                                                                                                                      #
#                                Bluecare agent provider for ITM6 Cookbook                                             #
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

action :install do
  converge_by("Create #{@new_resource}") do
    case node['platform']
    when 'windows'
       install_bluecare_agent

    when 'redhat'
      Chef::Log.debug("node['itm6']['bc_installed'] = #{node['itm6']['bc_installed']}")
      Chef::Log.debug("node['itm6']['bc_installedversion'] = #{node['itm6']['bc_installedversion']}")
     
      if ::File.exist?((node['itm6']['alreadyInstalledFileBC']).to_s)
        Chef::Log.info('Bluecare agent already installed......Nothing to do')
        if (node['itm6']['alreadyConfigured']).to_s == 'yes'
          node.default['itm6']['config_bc'] = 'done'
        end
      else
        Chef::Log.info("Bluecare product #{node['itm6']['bc_product']} not installed")
        install_bluecare_agent
      end

    when 'aix'
      Chef::Log.debug("node['itm6']['bc_installed'] = #{node['itm6']['bc_installed']}")
      Chef::Log.debug("node['itm6']['bc_installedversion'] = #{node['itm6']['bc_installedversion']}")

      if ::File.exist?((node['itm6']['alreadyInstalledFileBC']).to_s)
        Chef::Log.info('Bluecare agent already installed......Nothing to do')
        if (node['itm6']['alreadyConfigured']).to_s == 'yes'
          node.default['itm6']['config_bc'] = 'done'
        end
      else
        Chef::Log.info("Bluecare product #{node['itm6']['bc_product']} not installed")
        install_bluecare_agent
      end
    end
  end
end

# installing bluecare aent for linux
def install_bluecare_agent
  case node['platform']
  when 'windows'
    if ::File.exist?(node['itm6']['alreadyInstalledFile'].to_s)
      Chef::Log.info('Performing installation ...')
      ruby_block 'create-file' do
        block do
          execute 'install-agent' do
            cwd "C:\\itm6_temp\\NT_063007000\\K06"
            command '.\installIraAgent.bat "C:\\Program Files\\IBM\\ITM"'
            action :run
          end
        end
        action :create
      end
      Chef::Log.info('COMPLETE Bluecare agent installation done')
    end
  when 'redhat'
    Chef::Log.info("Bluecare installer found at : #{node['itm6']['bc_install_path']}")
    Chef::Log.info("Trying to install Bluecare agent using installation package #{node['itm6']['bc_package']}")

    if ::File.exist?((node['itm6']['bc_install_path']).to_s)
      Chef::Log.info('Performing installation ...')
      execute 'install-bcagent' do
        cwd (node['itm6']['bc_install_path']).to_s
        command './installIraAgent.sh /opt/IBM/ITM'
        action :run
        not_if { ::File.exist?((node['itm6']['alreadyInstalledFileBC']).to_s) }
      end
      Chef::Log.info("COMPLETE Bluecare agent #{node['itm6']['bc_product']} installation done")
      node.set['itm6']['bc_installed'] = '08'

      bc_product = '08'

      execute 'start-08-agent' do
        command "/opt/IBM/ITM/bin/itmcmd agent start #{bc_product}"
        action :run
	    ignore_failure true
      end

    ruby_block 'sleep-after-install' do
      block do
        sleep(60)
      end
      action :run
    end
    else
      Chef::Log.warn("#{node['itm6']['bc_install_path']} does not exists")
    end

    # installing for aix
    when 'aix'
    Chef::Log.info("Bluecare installer found at : #{node['itm6']['bc_install_path']}")
    Chef::Log.info("Trying to install Bluecare agent using installation package #{node['itm6']['bc_package']}")

    if ::File.exist?((node['itm6']['bc_install_path']).to_s)
      Chef::Log.info('Performing installation ...')
      execute 'install-bcagent' do
        cwd (node['itm6']['bc_install_path']).to_s
        command './installIraAgent.sh /opt/IBM/ITM'
        action :run
        not_if { ::File.exist?((node['itm6']['alreadyInstalledFileBC']).to_s) }
      end
      Chef::Log.info("COMPLETE Bluecare agent #{node['itm6']['bc_product']} installation done")
      node.default['itm6']['bc_installed'] = '07'
      # node.default['itm6']['bc_product'] = '08'
    else
      Chef::Log.warn("#{node['itm6']['bc_install_path']} does not exists")
    end
  end
end

action :installifix do
  converge_by("Create #{@new_resource}") do
    case node['platform']
    when 'windows'
      Chef::Log.info("Setting env path")
      powershell_script 'set_env_path' do
        code <<-EOH
          $env:Path='C:\\PROGRA~1\\IBM\\ITM\\InstallITM;C:\\PROGRA~1\\IBM\\ITM\\bin;C:\\PROGRA~1\\IBM\\ITM\\TMAITM6;$env:Path'
        EOH
      end
      if ::File.exist?(node['itm6']['ifix_temp'].to_s)
        Chef::Log.info("Stopping the monitoring agent")
        execute 'stop_Bluecare_agent' do
          cwd "#{node['itm6']['candlehome']}\\InstallITM"
          command '.\kinconfg.exe -pK06'
          action :run
        end
        execute 'stop_itm_agent' do 
          cwd "#{node['itm6']['candlehome']}\\InstallITM"
          command '.\kinconfg.exe -pKNT'
          action :run
        end
          ifix_counter = '0'
          ifix_counter_sucess = '0'
           #Dir.open("C:\\itm6_temp\\NT_063007000\\iFix\\").each do |ifix_dir|
            Dir.foreach("C:\\itm6_temp\\NT_063007000\\iFix\\") do |ifix_dir|
              if  Dir[ifix_dir].empty?
                Chef::Log.info("current ifix dir: " "#{ifix_dir}")
                install_location = "C:\\itm6_temp\\NT_063007000\\iFix\\#{ifix_dir}\\itmpatch.exe"
                 Chef::Log.info("Install Location: " "#{install_location}")
                 Dir.foreach("C:\\itm6_temp\\NT_063007000\\iFix\\#{ifix_dir}") do |file|
                  if  Dir[file].empty? 
                    if ("#{file}" != 'itmpatch.exe')
                      powershell_out ("cp C:\\PROGRA~1\\IBM\\ITM\\TMAITM6\\msvcp71.dll C:\\itm6_temp\\NT_063007000\\iFix\\#{ifix_dir}")
                      Chef::Log.info("ifix file: " "#{file}")
                      ifix_file="C:\\itm6_temp\\NT_063007000\\iFix\\#{ifix_dir}\\#{file}"
                      candle_home="C:\\PROGRA~1\\IBM\\ITM"
                      Chef::Log.info("Starting ifix installation for " "#{ifix_dir}//#{file}")
                      Chef::Log.info ("Patch install cmd: Start-Process -FilePath '#{install_location}' -ArgumentList '-h #{candle_home} -i #{ifix_file}' -Wait -PassThru")
                      ruby_block 'install_patch_ruby' do
                        block do
                           powershell_out("Start-Process -FilePath '#{install_location}' -ArgumentList '-h #{candle_home} -i #{ifix_file}' -Wait -PassThru >> C:\\itmpatchLog.txt 2>&1")
                        end
                        action :create
                      end
                        Chef::Log.info("Ifix Installation finish for " "#{ifix_dir}//#{file}")
                    end
                  end 
                 end
              end
            end
      else
        Chef::Log.info('No directory for IFix found ...')
      end 
    end
  end
end

action :configure do
  converge_by("Create #{@new_resource}") do
    case node['platform']
    when 'windows'
      if ::File.exist?(node['itm6']['alreadyInstalledFile'].to_s)
        Chef::Log.info('Configuring ITM agent ...')
        ruby_block 'configure_itm_agent' do
          block do
            line1 = '[Override Local Settings]'
            line2 = 'CTIRA_SUBSYSTEM_ID= '
            line3 = 'CTIRA_RECONNECT_WAIT=180'
            line4 = 'KDC_FAMILIES=@Protocol@ EPHEMERAL=Y HTTP_CONSOLE:N HTTP_SERVER:N HTTP:0 ip use:n ip.pipe use:n sna use:n'
            line5 = 'CTIRA_HIST_DIR=@LogPath@\History\@CanProd@'
            line6 = 'CTIRA_PRIMARY_FALLBACK_INTERVAL=900'
            line7 = "CTIRA_HOSTNAME=#{node['itm6']['agentname']}.TYPE=REG_EXPAND_SZ"
            line8 = "CTIRA_SYSTEM_NAME=#{node['itm6']['agentname']}"
            line9 = 'KDEB_INTERFACELIST_IPV6=-'
            file = Chef::Util::FileEdit.new("#{node['itm6']['candlehome']}\\TMAITM6_x64\\kntcma.ini")
            file.insert_line_if_no_match(/#{line1}/, line1)
            file.insert_line_if_no_match(/#{line2}/, line2)
            file.insert_line_if_no_match(/#{line3}/, line3)
            file.insert_line_if_no_match(/#{line4}/, line4)
            file.insert_line_if_no_match(/#{line6}/, line5)
            file.insert_line_if_no_match(/#{line7}/, line6)
            file.insert_line_if_no_match(/#{line8}/, line7)
            file.insert_line_if_no_match(/#{line9}/, line8)
            file.write_file
            end
          action :create
        end
        
        Chef::Log.info('configuring the bluecare agent')
        ruby_block 'configure_bluecare_agent' do
          block do
            line1 = '[Override Local Settings]'
            line2 = 'CTIRA_SUBSYSTEM_ID= '
            line3 = 'CTIRA_RECONNECT_WAIT=180'
            line4 = 'KDC_FAMILIES=@Protocol@ EPHEMERAL=Y HTTP_CONSOLE:N HTTP_SERVER:N HTTP:0 ip use:n ip.pipe use:n sna use:n'
            line5 = 'CTIRA_HIST_DIR=@LogPath@\History\@CanProd@'
            line6 = 'CTIRA_PRIMARY_FALLBACK_INTERVAL=900'
            line7 = "CTIRA_HOSTNAME=#{node['itm6']['agentname']}.TYPE=REG_EXPAND_SZ"
            line8 = "CTIRA_SYSTEM_NAME=#{node['itm6']['agentname']}"
            line9 = 'KDEB_INTERFACELIST_IPV6=-'
            file = Chef::Util::FileEdit.new("#{node['itm6']['candlehome']}\\TMAITM6_x64\\k06cma.ini")
            file.insert_line_if_no_match(/#{line1}/, line1)
            file.insert_line_if_no_match(/#{line3}/, line2)
            file.insert_line_if_no_match(/#{line5}/, line3)
            file.insert_line_if_no_match(/#{line6}/, line4)
            file.insert_line_if_no_match(/#{line7}/, line5)
            file.insert_line_if_no_match(/#{line8}/, line6)
            file.insert_line_if_no_match(/#{line9}/, line7)
            file.write_file
          end
          action :create
        end

        Chef::Log.info('downloading the ITM config files from pulp repo ...')
        remote_file node['itm6']['ITMconfig_EventLog'].to_s do
          source  node['itm6']['ITMconfig_EventLog'].to_s
          path "#{node['itm6']['configuration_dir_param']}\\K06_EventLog.param"
          action :create
        end
        remote_file node['itm6']['ITMconfig_LogiDisks'].to_s do
          source  node['itm6']['ITMconfig_LogiDisks'].to_s
          path "#{node['itm6']['configuration_dir_param']}\\K06_LogicalDisks.param"
          action :create
        end
        remote_file node['itm6']['ITMconfig_Processes'].to_s do
          source  node['itm6']['ITMconfig_Processes'].to_s
          path "#{node['itm6']['configuration_dir_param']}\\K06_Processes.param"
          action :create
        end
        remote_file node['itm6']['ITMconfig_Services'].to_s do
          source  node['itm6']['ITMconfig_Services'].to_s
          path "#{node['itm6']['configuration_dir_param']}\\K06_Services.param"
          action :create
        end

        Chef::Log.info("Reconfiguring the monitoring agent")
         ruby_block 'Reconfiguring_itm_agent' do
          block do
            powershell_out("C:\\PROGRA~1\\IBM\\ITM\\InstallITM\\kinconfg.exe -n'C:/itm6_temp/silent_config.txt' -rKNT")
          end
          action :create
        end
         ruby_block 'Reconfiguring_bluecare_agent' do
          block do
            powershell_out("C:\\PROGRA~1\\IBM\\ITM\\InstallITM\\kinconfg.exe -n'C:/itm6_temp/silent_config.txt' -rK06")
          end
          action :create
        end
       
        Chef::Log.info("Starting the monitoring agent")
          execute 'start_itm_agent' do
            cwd "#{node['itm6']['candlehome']}\\InstallITM"
            command '.\kinconfg.exe -sKNT'
            action :run
          end
          execute 'start_Bluecare_agent' do
           cwd "#{node['itm6']['candlehome']}\\InstallITM"
           command '.\kinconfg.exe -sK06'
           action :run
        end
       
        Chef::Log.info('deleting ITM temp dir ...')
        directory node['itm6']['temp'].to_s do
          recursive true
          action :delete
        end
      end
    # configuring for linux
    when 'redhat'
      if (node['itm6']['alreadyConfigured']).to_s != 'yes'
        ibm_itm6_itm6agent 'configure-itm6agent' do
           action [:configure]
        end
        if node['itm6']['bc_installed'].to_s != ''
          bc_product = '08'
          node.default['itm6']['bc_config_ini'] = (node['itm6']['configuration_directory']).to_s + '/' + "#{bc_product}.ini"
          replace_system_name = `cat #{node['itm6']['bc_config_ini']} | sed 's/^CTIRA_SYSTEM_NAME=.*/CTIRA_SYSTEM_NAME='#{node['itm6']['agentname']}'/g' > #{node['itm6']['bc_config_ini']}.tmp`
          replace_hostname = `cat #{node['itm6']['bc_config_ini']}.tmp | sed 's/^CTIRA_HOSTNAME=.*/CTIRA_HOSTNAME='#{node['itm6']['agentname']}'/g' > #{node['itm6']['bc_config_ini']}`

          line_edit_bc = ['CTIRA_SUBSYSTEM_ID=', 'CTIRA_RECONNECT_WAIT=180', 'CTIRA_PRIMARY_FALLBACK_INTERVAL=900', 'KDEB_INTERFACELIST_IPV6=-', 'KDC_FAMILIES=$NETWORKPROTOCOL$ EPHEMERAL:Y HTTP_CONSOLE:N HTTP_SERVER:N HTTP:0 ip use:n ip.pipe use:n sna use:n']
          line_edit_bc.each do |line|
            execute 'update ini file' do
              command "echo #{line} >> #{node['itm6']['bc_config_ini']}"
              action :run
            end
          end

          bc_product = '08'
          Chef::Log.info('Performing silent configuration')
          if ::File.exist?((node['itm6']['silentconfig']).to_s)
		    bc_agent_stop = `/opt/IBM/ITM/bin/itmcmd agent stop #{bc_product}`
		    execute 'stop-08-agent' do
              command "/opt/IBM/ITM/bin/itmcmd agent stop #{bc_product}"
              action :run
              ignore_failure true
            end
            # configure_bcagent = `/opt/IBM/ITM/bin/itmcmd config -A -p #{node['itm6']['silentconfig']} #{bc_product}`
            execute 'config-08-agent' do
              command "/opt/IBM/ITM/bin/itmcmd config -A -p #{node['itm6']['silentconfig']} 08"
              action :run
            end
          else

			execute 'export-config-08-agent' do
              command "/opt/IBM/ITM/bin/itmcmd resp #{node['itm6']['product']}"
              action :run
            end

			execute 'config-08-agent' do
              command "/opt/IBM/ITM/bin/itmcmd config -A -p #{node['itm6']['silentconfig']} 08"
              action :run
            end
          end
          Chef::Log.info('COMPLETE ITM6 silent configuration done')

		  execute 'start-08-agent' do
            command "/opt/IBM/ITM/bin/itmcmd agent start #{bc_product}"
            action :run
            ignore_failure true
          end

          defaultconfig = "#{node['itm6']['repository']}"
          if ::File.exist?(defaultconfig.to_s)
            Chef::Log.info('Copying default config files.........')

            execute 'copy_config_files' do
              command "cp #{defaultconfig}/K#{node['itm6']['bc_product']}* /opt/IBM/ITM/smitools/config"
              action :run
            end
            node.set['itm6']['alreadyConfigured'] = 'yes'
          end

          # removeing the temp directory
		  directory "#{node['itm6']['repository']}" do
            recursive true
            action :delete
          end
        else
          Chef::Log.warn('Nothing to configure !! Either Bluecare agent not installed or Agent already configured')
        end
      else
        Chef::Log.info('Bluecare already configured .....Nothing to do !!')
      end

    # configuring for aix
    when 'aix'
      if (node['itm6']['config_bc']).to_s != 'done'
        ibm_itm6_itm6agent 'configure-itm6agent' do
           action [:configure]
        end
        if node['itm6']['bc_installed'].to_s != ''
          bc_product = '07'
          node.default['itm6']['bc_config_ini'] = (node['itm6']['configuration_directory']).to_s + '/' + "#{bc_product}.ini"
          replace_system_name = `cat #{node['itm6']['bc_config_ini']} | sed 's/^CTIRA_SYSTEM_NAME=.*/CTIRA_SYSTEM_NAME='#{node['itm6']['agentname']}'/g' > #{node['itm6']['bc_config_ini']}.tmp`
          replace_hostname = `cat #{node['itm6']['bc_config_ini']}.tmp | sed 's/^CTIRA_HOSTNAME=.*/CTIRA_HOSTNAME='#{node['itm6']['agentname']}'/g' > #{node['itm6']['bc_config_ini']}`

          line_edit_bc = ['CTIRA_SUBSYSTEM_ID=', 'CTIRA_RECONNECT_WAIT=180', 'CTIRA_PRIMARY_FALLBACK_INTERVAL=900', 'KDEB_INTERFACELIST_IPV6=-', 'KDC_FAMILIES=$NETWORKPROTOCOL$ EPHEMERAL:Y HTTP_CONSOLE:N HTTP_SERVER:N HTTP:0 ip use:n ip.pipe use:n sna use:n']
          line_edit_bc.each do |line|
            execute 'update ini file' do
              command "echo #{line} >> #{node['itm6']['bc_config_ini']}"
              action :run
            end
          end

          bc_product = '07'
          Chef::Log.info('Performing silent configuration')

		  execute 'stop-bc-agent' do
            command "/opt/IBM/ITM/bin/itmcmd agent stop #{bc_product}"
            action :run
            ignore_failure true
          end

          if ::File.exist?((node['itm6']['silentconfig']).to_s)

            execute 'configure-bcagent' do
              command "/opt/IBM/ITM/bin/itmcmd config -A -p #{node['itm6']['silentconfig']} #{bc_product}"
              action :run
              ignore_failure true
            end
          else
            export_config = `/opt/IBM/ITM/bin/itmcmd resp #{node['itm6']['product']}`

			execute 'configure-bcagent' do
              command "/opt/IBM/ITM/bin/itmcmd config -A -p /opt/IBM/ITM/silent_config_#{node['itm6']['trigram']}.txt #{node['itm6']['bc_product']}"
              action :run
              ignore_failure true
            end
          end
          Chef::Log.info('COMPLETE ITM6 silent configuration done')

		  execute 'start-bc-agent' do
            command "/opt/IBM/ITM/bin/itmcmd agent start #{bc_product}"
            action :run
            ignore_failure true
          end

          defaultconfig = "#{node['itm6']['repository']}/"
          if ::File.exist?(defaultconfig.to_s)
            Chef::Log.info('Copying default config files.........')

            execute 'copy-config-files' do
              command "cp #{defaultconfig}/K#{node['itm6']['bc_product']}* /opt/IBM/ITM/smitools/config"
              action :run
            end
            node.set['itm6']['alreadyConfigured'] = 'yes'
          end

          # removeing the temp directory
		  directory "#{node['itm6']['repository']}" do
            recursive true
            action :delete
          end
        else
          Chef::Log.warn('Nothing to configure !! Either Bluecare agent not installed or Agent already configuredd')
        end
      else
        Chef::Log.info('Bluecare already configured .....Nothing to do !!')
      end
    end
  end
end

action :uninstall do
  converge_by("Create #{@new_resource}") do
    case node['platform']
    when 'windows'
      uninstall_bluecare
    when 'rhel'
      uninstall_blue_lin
    # uninstalling agent on aix
    when 'aix'
      if ::File.exist?((node['itm6']['alreadyInstalledFile']).to_s)
        node.default['itm6']['uninstall_cmd'] = (node['itm6']['uninstall_dir']).to_s + '/' + 'uninstall.sh'

        execute 'uninstalling-itm6' do
          command node['itm6']['uninstall_cmd'].to_s
          action :run
          returns [0, 1]
        end
      else
        Chef::Log.error('Bluecare Agent not installed......Skipping uninstallation')
      end
    end
  end
end

# uninstalling bluecare agent from linux
def uninstall_blue_lin
  case node['platform']
  when 'rhel'
    if ::File.exist?((node['itm6']['alreadyInstalledFile']).to_s)
      node.default['itm6']['uninstall_cmd'] = (node['itm6']['uninstall_dir']).to_s + '/' + 'uninstall.sh'

      execute 'uninstalling-itm6' do
        command node['itm6']['uninstall_cmd'].to_s
        action :run
        returns [0, 1]
      end
    else
      Chef::Log.error('Bluecare Agent not installed......Skipping uninstallation')
    end
  end
end

def uninstall_bluecare
  Chef::Log.info('Uninstall BlueCare agent ...')
  execute 'uninstall_bluecare' do
    cwd "#{node['itm6']['candlehome']}\\TMAITM6_x64"
    command '.\K06_uninstall.vbs '
    action :run
  end
end
