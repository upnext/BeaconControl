###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree.
###

require 'ostruct'

class ApplicationConfig
  MissingRequiredConfiguration = Class.new(StandardError)

  def initialize(file_path=nil, &block)
    config_file = File.expand_path('config/config.yml')
    config_file = File.expand_path('config/heroku_config.yml') unless File.exist? config_file
    @file_path = file_path || config_file
    @store = {}
    @config = {}
    instance_exec &block if block_given?
    load_config!
    validate!
  end

  def config_key(key, default: nil, mandatory: false)
    config = OpenStruct.new(key: key.to_s, default: default, mandatory: mandatory)
    @config[config.key] = config
    instance_eval "def #{config.key}; @store.fetch('#{config.key}', @config['#{config.key}'].default); end"
  end

  private

  def validate!
    @config.each_pair do |key, config|
      raise MissingRequiredConfiguration.new(key) if config.mandatory && @store[key].blank?
    end
  end

  def load_config!
    yaml = YAML.load_file(@file_path).fetch(Rails.env, {}).fetch('config', {})
    yaml.each_pair do |key, value|
      @store[key.to_s] = value.is_a?(Hash) ?
        ActiveSupport::HashWithIndifferentAccess.new(value) : value
    end
  end
end
