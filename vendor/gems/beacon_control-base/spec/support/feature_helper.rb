###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

def ep_message(event_type, range)
  {
    application:   application,
    user:          user,
    mobile_device: mobile_device,
    events:        [
      {
        event_type: event_type,
        timestamp:  Time.now,
        action_id:  1
      }.merge(range)
    ]
  }
end

def trigger_event(event_type='enter', range=beacon)
  range = {"#{range.is_a?(Beacon) ? 'range' : 'zone'}_id" => range.id}

  perform_enqueued_jobs do
    EventProcessor.process(ep_message(event_type, range))
  end
end

def fixture_content(file_name)
  File.read "spec/fixtures/#{file_name}"
end

def fixture_file_path(file_name="example_file.md")
  "spec/fixtures/files/#{file_name}"
end

def login_as(user)
  visit '/'
  fill_in :admin_email, with: user.email
  fill_in :admin_password, with: 'password'
  click_button 'Sign in'
  expect(page.text).to have_content(user.email)
end
