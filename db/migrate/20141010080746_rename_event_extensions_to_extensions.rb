###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class RenameEventExtensionsToExtensions < ActiveRecord::Migration
  def change
    drop_table   :extensions
    drop_table   :applications_extensions

    rename_table  :event_extensions, :extensions
    rename_table  :event_extension_assignments, :extension_assignments
    rename_table  :accounts_event_extensions,  :accounts_extensions
    rename_column :accounts_extensions,   :event_extension_id, :extension_id
    rename_column :extension_assignments, :event_extension_id, :extension_id
  end
end
