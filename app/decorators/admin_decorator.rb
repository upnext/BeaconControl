###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class AdminDecorator < Draper::Decorator
  delegate_all

  def beacons_to_select
    object.beacons.map {|b| [b.name, b.id] }
  end

  def role_names
    object.class.roles.keys.map do |role_name|
      [I18n.t("activerecord.attributes.admin.roles.#{role_name}"), role_name]
    end
  end
end
