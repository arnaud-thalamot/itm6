########################################################################################################################
#                                                                                                                      #
#                                            Main recipe for ITM6 Cookbook                                             #
#                                                                                                                      #
#   Language            : Chef/Ruby                                                                                    #
#   Date                : 01.03.2016                                                                                   #
#   Date Last Update    : 01.03.2016                                                                                   #
#   Version             : 0.4                                                                                          #
#   Author              : Arnaud THALAMOT                                                                              #
#                                                                                                                      #
########################################################################################################################
case node['platform']
when 'windows'
  ibm_itm6_itm6agent 'install-and-configure-itm6agent' do
    action [:install]
  end

when 'redhat'

  #selinux_backup = "#{node['cma_conf_selinux']['status']}"
  #node.override['cma_conf_selinux']['status'] = 'disabled'
  #include_recipe 'cma_conf_selinux'

  execute 'disable-selinux' do
      command 'setenforce 0'
      action :run
  end

  ibm_itm6_itm6agent 'install-and-configure-itm6agent' do
    action [:preinstall, :install]
  end

  ibm_itm6_bluecareagent 'install-and-configure-bluecareagent' do
    action [:install, :configure]
  end

  execute 'restore-context-jre-bin' do
      command 'semanage fcontext -a -t textrel_shlib_t "/opt/IBM/ITM/JRE/lx8266/bin(/.*)?"'
      action :run
  end

  execute 'restore-context-jre-lib' do
      command 'semanage fcontext -a -t textrel_shlib_t "/opt/IBM/ITM/tmaitm6/lx8266/lib(/.*)?"'
      action :run
  end

  execute 'restorecon-jre-bin' do
      command 'restorecon -R /opt/IBM/ITM/JRE/lx8266/bin'
      action :run
  end

  execute 'restorecon-jre-lib' do
      command 'restorecon -R /opt/IBM/ITM/tmaitm6/lx8266/lib'
      action :run
  end

  execute 'enable-selinux' do
      command 'setenforce 1'
      action :run
  end

  #node.override['cma_conf_selinux']['status'] = 'enforced'
  #include_recipe 'cma_conf_selinux'

when 'aix'
  ibm_itm6_itm6agent 'install-and-configure-itm6agent' do
    action [:preinstall, :install]
  end

  ibm_itm6_bluecareagent 'install-configure-bluecare-aix' do
    action [:install, :configure]
  end
end

node.set['itm6']['status'] = 'success'
