###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module KontaktIoExtension
    class ExtensionsMarketplaceController < ::ExtensionsMarketplaceController
      before_action :check_api_validity, only: [:update]

      def update
        if is_save?
          @account_extension.save
          render :edit
        else
          render 'extensions_marketplace/edit'
        end
      end

      private

      #
      # Test API key by fetching Kontakt.io managers. Catch +KontaktIo::Error+ and displays its message on form.
      #
      def check_api_validity
        @account_extension.assign_attributes(permitted_params)
        @beacons_count = api_client.beacons.size
        @valid = true
      rescue KontaktIo::Error => e
        @valid = false
        @account_extension.extension_setting(:api_key).errors.add(:value, e.message)
      end

      #
      # Decides if submitted form should be saved, or just validated against Kontakt.io
      # API key correctness.
      #
      def is_save?
        @valid && params[:valid] == 'true' && params[:commit] == 'save'
      end

      def api_client
        @api_client ||= KontaktIo::ApiClient.new(@account_extension.extension_setting(:api_key).value)
      end
    end
  end
end
