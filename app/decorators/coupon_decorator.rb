###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class CouponDecorator < Draper::Decorator
  delegate_all

  def templates_list
    templates.map {|t| [I18n.t("templates.#{t}"), t] }
  end

  def encoding_types_list
    encoding_types.map {|type| [type.humanize, type] }
  end

  private

  def templates
    Coupon::TEMPLATES
  end

  def encoding_types
    Coupon.encoding_types.keys
  end
end

