###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module S2sApi
  module V1
    class ZoneWithoutBeaconsSerializer < BaseSerializer
      attributes :id, :name, :color, :hex_color
    end
  end
end
