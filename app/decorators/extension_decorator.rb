###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class ExtensionDecorator < Draper::Decorator
  delegate_all

  def assignment
    extension_assignments.find_by(application_id: h.current_admin.applications.first.id)
  end
end
