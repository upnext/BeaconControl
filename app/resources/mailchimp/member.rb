module Mailchimp
  class Member
    include Virtus.model
    include Mixin

    resources_path '/lists/:list_id/members'
  end
end