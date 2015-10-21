module Mailchimp
  class List
    include Virtus.model
    include Mixin

    attribute :id, String
    attribute :name, String
    attribute :contact, Contact
    attribute :permission_reminder, String
    attribute :use_archive_bar, Boolean
    attribute :campaign_defaults, Hash
    attribute :notify_on_subscribe, String
    attribute :notify_on_unsubscribe, String
    attribute :date_created, DateTime
    attribute :list_rating, Fixnum
    attribute :email_type_option, Boolean
    attribute :subscribe_url_short, String
    attribute :subscribe_url_long, String
    attribute :beamer_address, String
    attribute :visibility, String
    attribute :modules, Array
    attribute :stats, Stats

    has_many :members
  end
end