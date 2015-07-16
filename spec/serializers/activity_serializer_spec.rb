###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'rails_helper'

describe ActivitySerializer do
  let!(:activity) { FactoryGirl.create(:url_activity) }

  let(:serialized) { described_class.new(activity).as_json(root: false) }

  it 'includes all needed attributes' do
    expect(serialized).to include(:id, :name, :type, :payload, :custom_attributes)
  end
end
