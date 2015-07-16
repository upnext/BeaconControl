###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class Brand

  #
  # Factory for Brand model.
  #
  class Factory
    def initialize(params)
      self.brand = Brand.new(params)
    end

    def create
      brand.tap do |brand|
        if brand.save
          doorkeeper_app = Doorkeeper::Application.new(
            name: brand.name, redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
          )
          doorkeeper_app.owner = brand
          doorkeeper_app.save!
        end
      end
    end

    private

    attr_accessor :brand
  end
end
