###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class RemoveTriggerIdFromActivities < ActiveRecord::Migration
  def up
    Activity.where.not(trigger_id: nil).each do |activity|
      Trigger.find(activity.trigger_id).update_attribute :activity_id, activity.id
    end

    remove_column :activities, :trigger_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
