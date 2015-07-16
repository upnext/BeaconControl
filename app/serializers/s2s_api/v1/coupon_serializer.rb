###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module S2sApi
  module V1
    class CouponSerializer < BaseSerializer
      attributes :id, :name, :template, :title, :description

      has_one :image
      has_one :logo

      def attributes(*args)
        hash = super

        hash.merge! with_attributes([:encoding_type, :unique_identifier_number, :identifier_number], :with_barcode?)
        hash.merge! with_attributes([:button_font_color, :button_background_color, :button_label, :button_link], :with_button?)

        hash
      end
    end
  end
end
