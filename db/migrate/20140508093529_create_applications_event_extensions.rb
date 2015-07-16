###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class CreateApplicationsEventExtensions < ActiveRecord::Migration
  def change
    create_table :applications_event_extensions, id: false do |t|
      t.references :application
      t.references :event_extension
    end

    add_index :applications_event_extensions,
      [:application_id, :event_extension_id],
      name: :applications_event_extensions_index

    add_index :applications_event_extensions, :event_extension_id
  end
end
