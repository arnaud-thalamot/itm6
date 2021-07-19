########################################################################################################################
#                                                                                                                      #
#                                          Ostype Resource for ITM6 Cookbook                                           #
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

action :get do
  converge_by("Create #{@new_resource}") do
    if platform_family?('windows')
      batch 'get-basedir' do
        code <<-EOH
        #{node['itm6']['basedir']}=%~dp0
        EOH
      end
      batch 'set-tmp' do
        code <<-EOH
        #{node['itm6']['userprofile']}=%USERPROFILE%
        EOH
      end
      batch 'set-temp' do
        code <<-EOH
        set TEMP=%USERPROFILE%\Local Settings\Temp
        EOH
      end
      batch 'set-tmp' do
        code <<-EOH
        set TMP=%USERPROFILE%\Local Settings\Temp
        EOH
      end
      directory "node['itm6']['userprofile']\Local Settings" do
        action :create
      end
      directory "node['itm6']['userprofile']\Local Settings\Temp" do
        action :create
      end
      node.default['itm6']['install_dir'] = "node['itm6']['basedir']\NT_063004000_WIX64"
    else
      Chef::Log.info('Determining OS type and architecture')
      node.default['itm6']['ostype'] = `uname`
      node.default['itm6']['ostype'] = (node['itm6']['ostype']).to_s.chop
      Chef::Log.debug("node['itm6']['ostype'] = #{node['itm6']['ostype']}")

      case node['itm6']['ostype']
      when 'Linux'
        uname_m = `uname -m`
        Chef::Log.debug("uname_m = #{uname_m}")
        node.default['itm6']['arch'] = if uname_m == 'i686' || uname_m == 's390'
                                         'l' + `echo $(uname -m|cut -c1-2)$(uname -r|cut -c1)$(uname -r|cut -c3)`.chop + '3'
                                       else
                                         'l' + `echo $(uname -m|cut -c1-2)$(uname -r|cut -c1)$(uname -r|cut -c3)`.chop + '6'
                                       end
        node.default['itm6']['product'] = 'lz'
        node.default['itm6']['bc_product'] = '08'
        node.default['itm6']['bc_lastversion'] = '02200009'
        node.default['itm6']['bc_packageversion'] = '022000009'

      when 'Aix'

        if File.exist?(node['itm6']['vio_evidence'])
          raise 'ERROR We are on VIO server, nothing to do'
        end
        node.default['itm6']['arch'] = 'aix' + `echo $(uname -v)$(uname -r)$(/usr/sbin/bootinfo -K | cut -c1)`.chop
        node.default['itm6']['product'] = 'ux'
        node.default['itm6']['bc_product'] = '07'
        node.default['itm6']['bc_lastversion'] = '02310005'
        node.default['itm6']['bc_packageversion'] = '023100005'

      else
        raise "ERROR Unknown ostype #{node['itm6']['ostype']}"
      end

      Chef::Log.debug("node['itm6']['arch'] = #{node['itm6']['arch']}")
      Chef::Log.debug("node['itm6']['product'] = #{node['itm6']['product']}")
      Chef::Log.debug("node['itm6']['bc_product'] = #{node['itm6']['bc_product']}")
      Chef::Log.debug("node['itm6']['bc_lastversion'] = #{node['itm6']['bc_lastversion']}")
      Chef::Log.debug("node['itm6']['bc_packageversion'] = #{node['itm6']['bc_packageversion']}")

      case node['itm6']['arch']
      when 'aix523', 'aix526'
        raise 'ERROR AIX 5.2 is not supported'
      when 'aix536'
        node.default['itm6']['lastversion'] = '06230400'
        node.default['itm6']['media'] = 'aix526'
      when 'aix533'
        node.default['itm6']['lastversion'] = '06230400'
        node.default['itm6']['media'] = 'aix523'
      when 'aix616', 'aix716'
        node.default['itm6']['media'] = 'aix526'
      when 'aix613', 'aix713'
        node.default['itm6']['media'] = 'aix523'
      else
        node.default['itm6']['media'] = node['itm6']['arch']
      end
      Chef::Log.debug("node['itm6']['last version'] = #{node['itm6']['lastversion']}")
      Chef::Log.debug("node['itm6']['media'] = #{node['itm6']['media']}")
    end
  end
end
