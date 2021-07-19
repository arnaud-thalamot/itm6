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

ibm_itm6_itm6agent 'uninstall-itm6agent' do
  action [:uninstall]
end
ibm_itm6_bluecareagent 'uninstall-blueCare' do
  action [:uninstall]
end