module S2sApi
  module V1
    class VendorsController < BaseController
      inherit_resources
      self.responder = S2sApiResponder

      def index
        render json: ::Beacon::VENDORS
      end
    end
  end
end
