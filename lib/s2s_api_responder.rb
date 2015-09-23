###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class S2sApiResponder < ActionController::Responder
  def json_resource_errors
    { errors: resource.errors.messages }.to_json
  end

  protected

  def api_behavior
    if delete? && resource.try(:persisted?)
      display_errors
    else
      super
    end
  end

  def display(resource, opts={})
    super(resource, opts.merge!(controller: @controller))
  end
end
