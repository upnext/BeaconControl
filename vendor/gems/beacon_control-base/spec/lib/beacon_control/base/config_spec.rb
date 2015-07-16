###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'spec_helper'

describe 'BeaconControl::Base::Config' do
  let!(:extension) { TestOs::TestExtension }

  it "keeps registered sidebar links" do
    sidebar_link_config = {a: 1, b: 2}
    extension.configure { |config|
      config.register :sidebar_links, sidebar_link_config
    }

    expect(extension.config.registers[:sidebar_links]).to include(sidebar_link_config)
  end
end
