###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class ApplicationDecorator < Draper::Decorator
  delegate_all

  def created_at
    object.created_at.strftime("%d.%m.%Y, %H:%M:%S")
  end

  def name
    if object.test?
      "#{object.name} (#{Application.human_attribute_name(:test)})"
    else
      object.name
    end
  end
end
