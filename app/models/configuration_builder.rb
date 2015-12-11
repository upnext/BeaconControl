###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'deep_merge/rails_compat'

class ConfigurationBuilder
  def initialize(application)
    self.application = application
  end

  #
  # Constructs JSON of application configuration options.
  #
  # ==== Example result
  #
  #   {:extensions=>{:presence=>{:zones=>[1, 2, 3], :ranges=>[1, 2, 3]}},
  #   :zones=>[{:id=>1, :name=>"Zone 1", :beacon_ids=>[1]}, {:id=>2, :name=>"Zone 2", :beacon_ids=>[2, 3]}, {:id=>3, :name=>"Zone 3", :beacon_ids=>[]}],
  #   :ranges=>
  #     [{:id=>1,
  #       :name=>"Beacon 1",
  #       :proximity_id=>"8DD8E67D-89C7-4916-ACB9-153F63927CD0+5+8",
  #       :location=>{:lat=>#<BigDecimal:34e59f0,'0.52310066E2',18(18)>, :lng=>#<BigDecimal:34e5860,'0.13239984E2',18(18)>, :floor=>nil}},
  #      {:id=>2, :name=>"Beacon 2", :proximity_id=>"E01E906F-63CA-4381-B775-54901FBE6BF9+0+1", :location=>{:lat=>nil, :lng=>nil, :floor=>nil}},
  #      {:id=>3, :name=>"Beacon 3", :proximity_id=>"030E3AF1-2BEC-4329-B6E4-EF3747A73C5A+3+1", :location=>{:lat=>nil, :lng=>nil, :floor=>nil}}],
  #   :triggers=>
  #     [{:id=>1, :conditions=>[{:event_type=>"enter", :type=>:event_type}], :range_ids=>[],
  #       :actions=>[{:id=>1, :type=>"sample", :name=>"sample", :payload=>{}}]},
  #      {:id=>2, :conditions=>[{:event_type=>"enter", :type=>:event_type}], :zone_ids=>[1],
  #       :actions=>[{:id=>2, :type=>"coupon", :name=>"foo", :payload=>{:url=>"http:///mobile/coupons/1"}}]}],
  #   :ttl=>86400}
  #
  def as_json
    json = {
      vendors: ::Beacon::VENDORS
    }.with_indifferent_access

    extensions.each do |extension|
      name = extension.name.gsub(/\./, '_').camelize
      extension_data_class = begin
        "ExtensionData::#{name}".constantize
      rescue NameError
        nil
      end

      if extension_data_class.present?
        extension_config = extension_data_class.new(application)
        if extension_config.respond_to?(:merge!)
          extension_config.merge!(json)
        else
          json.deeper_merge!(extension_config.as_json.with_indifferent_access)
        end
      end
    end

    json
  end

  private

  def extensions
    default_extension + application.active_extensions
  end

  #
  # To include information about application Trigger in its configuration JSON.
  #
  def default_extension # :doc:
    [OpenStruct.new(name: 'Triggers')]
  end

  attr_accessor :application
end
