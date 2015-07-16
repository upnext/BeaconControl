###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class ActivityDecorator < Draper::Decorator
  delegate_all

  decorates_association :coupon

  def edit_link(application)
    h.link_to '<span class="fa fa-pencil"></span>'.html_safe, h.edit_application_activity_path(application, object)
  end

  def destroy_link(application)
    h.link_to_modal :cancel_icon, h.application_activity_path(application, activity), '#destroy-modal'
  end

  def delete_checkbox
    h.content_tag(:label, class: %W[styled-checkbox styled-checkbox-fa]) do
      h.concat h.check_box_tag "id[]", id, false, class: %W[batch-delete-check]
      h.concat h.content_tag(:span, nil, class: %W[fa fa-check])
    end
  end

  def url
    object.url.sub(/\Ahttps?:\/\//, '') if object.url
  end

  private

  def edit_icon
    h.glyphicon(:pencil)
  end

  def destroy_icon
    h.glyphicon(:trash)
  end
end
