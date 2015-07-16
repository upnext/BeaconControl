###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module S2sApi
  module V1
    class ActivitySerializer < BaseSerializer
      attributes :id, :name, :scheme, :payload, :trigger

      has_one :trigger, serializer: S2sApi::V1::TriggerSerializer

      has_many :custom_attributes

      def attributes(*args)
        hash = super

        hash.merge! CouponSerializer.new(object.coupon).as_json if object.coupon.present?

        hash
      end
    end
  end
end
