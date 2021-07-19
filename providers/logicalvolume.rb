########################################################################################################################
#                                                                                                                      #
#                                  Logical volume provider for ITM6 Cookbook                                           #
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
    # Check that /opt/IBM/ITM is a dedicated FS
    fs_exists = 0
    execute 'test_fs' do
      command "#{fs_exists}=$(df -Pk | grep #{default['itm6']['logical_volume_name']} | wc -l)"
      action :run
    end
    if fs_exists == 0
      log 'status' do
        message 'ERROR No dedicated /opt/IBM/ITM FS exists'
        level :fatal
      end
      raise 'ERROR No dedicated /opt/IBM/ITM FS exists'
    end
  end
end
