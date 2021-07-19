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


actions :install, :installifix, :configure, :uninstall

attribute :arch, String

def initialize(*args)
  super
  @action = :install
end
