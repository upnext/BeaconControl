###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class RemoveExtensionsFromDatabase < ActiveRecord::Migration
  def change
    drop_table :extensions

    remove_index :extension_assignments, :extension_id
    remove_column :extension_assignments, :extension_id
    add_column :extension_assignments, :extension_name, :string, null: false
    add_index :extension_assignments, [:application_id, :extension_name], unique: true, name: 'index_applications_extensions'

    remove_index :accounts_extensions, :extension_id
    remove_column :accounts_extensions, :extension_id
    add_column :accounts_extensions, :extension_name, :string, null: false
    add_index :accounts_extensions, [:account_id, :extension_name], unique: true

    rename_table :accounts_extensions,   :account_extensions
    rename_table :extension_assignments, :application_extensions
  end
end
