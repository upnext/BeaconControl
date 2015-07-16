###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class MoveDataToEeAssignments < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
      execute <<-SQL
        CREATE OR REPLACE FUNCTION UTC_TIMESTAMP() RETURNS timestamp AS $$
          SELECT NOW() AT time zone 'utc';
        $$ language sql
      SQL
    end

    execute <<-SQL
      INSERT INTO event_extension_assignments
        (event_extension_id,
        application_id,
        configuration,
        created_at,
        updated_at)
      SELECT event_extension_id,
        application_id,
        '--- {}\n',
        UTC_TIMESTAMP(),
        UTC_TIMESTAMP()
      FROM applications_event_extensions
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
