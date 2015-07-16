###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module TestOs
  module TestExtension
    include BeaconControl::Base::Extension

    self.registered_name = "Test"
  end
end
