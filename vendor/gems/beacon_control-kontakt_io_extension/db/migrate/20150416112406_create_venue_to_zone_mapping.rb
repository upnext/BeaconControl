###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class CreateVenueToZoneMapping < ActiveRecord::Migration
  def change
    create_table :ext_kontakt_io_mapping do |t|
      t.string  :target_type
      t.integer :target_id
      t.string  :kontakt_uid
    end
  end
end
