###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class ActivityParams
  attr_accessor :params, :raw_params

  def initialize(params)
    self.raw_params = params
    self.params     = permit_params(activity_params)
  end

  #
  # Creates +ActionController::Parameters+ object with initialized values for activity +permitted_attributes+.
  #
  def call
    params
  end

  private

  def activity_params
    ret_params = raw_params.fetch(:activity, {})
    (ret_params[:trigger_attributes] || {}).merge!(application_params)

    ret_params
  end

  def application_params
    { application_id: raw_params[:application_id] }
  end

  def permit_params(params)
    ActionController::Parameters.new(params).permit(ActivityParams.permitted_attributes)
  end

  #
  # Construct Hash of all params that are permitted, including those added by extensions.
  #
  def self.nested_permitted_attributes # :doc:
    {
      trigger_attributes: [
        :id, :type, :application_id, :event_type, :test,
        *ExtensionsRegistry.extensions_trigger_permitted_attributes,
         beacon_ids: [], zone_ids: []
      ],
      custom_attributes_attributes: [
        :id, :name, :value, :_destroy
      ],
      coupon_attributes: [
        :id, :template, :name, :title, :description,
        :logo_cache, :image_cache,
        :unique_identifier_number, :identifier_number, :encoding_type,
        :button_label, :button_font_color, :button_background_color,
        :button_link,
        logo_attributes: [
          :id, :file, :type, :file_cache, :remove_file
        ],
        image_attributes: [
          :id, :file, :type, :file_cache, :remove_file
        ]
      ]
    }.merge(ExtensionsRegistry.extensions_actions_permitted_attributes)
  end

  def self.permitted_attributes
    [ :name, :url, :scheme, :campaign_id, :protocol, ActivityParams.nested_permitted_attributes ]
  end
end
