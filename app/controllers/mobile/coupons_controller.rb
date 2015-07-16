###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module Mobile
  class CouponsController < BaseController
    layout 'mobile'

    def show
      @coupon = Coupon.find(params[:id])

      render "coupons/templates/#{@coupon.template}/show"
    end

    def barcode
      @coupon = Coupon.find(params[:coupon_id])

      render inline: @coupon.barcode
    end
  end
end
