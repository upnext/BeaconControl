###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class AddAdminIdToBeacon < ActiveRecord::Migration
  class Admin < ActiveRecord::Base
  end

  def up
    id = Admin.first.try(:id)

    add_column :beacons, :admin_id, :integer

    if id
      execute <<-SQL
        UPDATE beacons SET admin_id = #{id}
      SQL
    end
  end

  def down
    remove_column :beacons, :admin_id
  end
end
