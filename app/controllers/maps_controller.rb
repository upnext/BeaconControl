###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class MapsController < ApplicationController
  before_filter :authenticate_admin!

  def show
    @form = BeaconFilterForm.new(current_admin.account, current_ability)
  end
end
