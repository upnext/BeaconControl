###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module IconsHelper
  def bos_icon(icon, title = nil)
    [
      (content_tag :span, '', class: %W[bos bos-#{icon}]),
      title
    ].compact.join(' ').html_safe
  end

  def awesome_icon(icon, title = nil)
    [
      (content_tag :span, '', class: %W[fa fa-#{icon}]),
      title
    ].compact.join(' ').html_safe
  end
end
