module Mailchimp
  class Stats
    include Virtus.model
    include Mixin

    attribute :member_count, Fixnum
    attribute :unsubscribe_count, Fixnum
    attribute :cleaned_count, Fixnum
    attribute :member_count_since_send, Fixnum
    attribute :unsubscribe_count_since_send, Fixnum
    attribute :cleaned_count_since_send, Fixnum
    attribute :campaign_count, Fixnum
    attribute :campaign_last_sent, String
    attribute :merge_field_count, Fixnum
    attribute :avg_sub_rate, Fixnum
    attribute :avg_unsub_rate, Fixnum
    attribute :target_sub_rate, Fixnum
    attribute :open_rate, Fixnum
    attribute :click_rate, Fixnum
    attribute :last_sub_date, DateTime
    attribute :last_unsub_date, String
  end
end