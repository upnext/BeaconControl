###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class Beacon < ActiveRecord::Base
  belongs_to :admin
  belongs_to :account
end

class Account < ActiveRecord::Base
end

class Admin < ActiveRecord::Base
  belongs_to :account
end

class ChangeBeaconsToBelongsToAccounts < ActiveRecord::Migration
  def change
    add_column :beacons, :account_id, :integer

    reversible do |dir|
      dir.up do
        Beacon.all.each do |b|
          b.account = b.admin.account if b.admin
          b.save
        end
      end
    end
  end
end
