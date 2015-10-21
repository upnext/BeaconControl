module Mailchimp
  class Contact
    include Virtus.model
    include Mixin

    attribute :company, String
    attribute :address1, String
    attribute :address2, String
    attribute :city, String
    attribute :zip, String
    attribute :country, String
    attribute :phone, String
  end
end