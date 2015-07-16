###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'spec_helper'

describe 'BeaconControl::Base::Extension' do
  it "defines registered_name and table_name_prefix" do
    expect(TestOs::TestExtension.registered_name).to eq("Test")

    expect{TestOs::TestExtension.send(:table_name_prefix)}.not_to raise_error
    expect(TestOs::TestExtension.table_name_prefix).to eq("ext_test_")

    TestOs::TestExtension.registered_name = "Foo"
    expect(TestOs::TestExtension.table_name_prefix).to eq("ext_foo_")
  end
end
