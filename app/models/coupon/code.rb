###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'barby'
require 'barby/barcode/qr_code'
require 'barby/barcode/code_128'
require 'barby/outputter/svg_outputter'

class Coupon

  #
  # Coupon Barcode/QRcode image generator.
  #
  class Code

    #
    # Options for specific code type:
    # * +xdim+   - Width of generated SVG
    # * +height+ - Height of generated SVG, valid only for +code_128+ type
    #
    MAPPING = {
      qr_code: {
        name: 'QrCode',
        xdim: 4,
        height: 100,
      },
      code_128: {
        name: 'Code128B',
        xdim: 2,
        height: 40,
      },
    }

    delegate :unique_identifier_number, :encoding_type, to: :coupon

    def initialize(coupon)
      self.coupon = coupon
    end

    #
    # Generates svg string for given coupon, only if it has supported template.
    #
    def to_image(options = {})
      return '' if unique_identifier_number.blank?

      code.to_svg(default_options.merge(options))
    end

    private

    def default_options
      type.slice(:xdim, :height)
    end

    def generator
      "Barby::#{encoding_name}".constantize
    end

    def encoding_name
      type[:name]
    end

    def type
      MAPPING[encoding_type.to_sym]
    end

    def code
      generator.new(unique_identifier_number.to_s)
    end

    attr_accessor :coupon
  end
end
