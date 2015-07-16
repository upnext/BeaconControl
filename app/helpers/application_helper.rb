###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module ApplicationHelper

  #
  # Pick the correct arguments for form_for when shallow routes are used.
  #
  # ==== Parameters
  #
  # * +parent+ - The Resource that has_* child
  # * +child+  - The Resource that belongs_to parent
  #
  def shallow_args(parent, child)
    child.try(:new_record?) ? [parent, child] : child
  end

  def glyphicon(name, text = nil)
    if text.present?
      "<span class=\"glyphicon glyphicon-#{name}\"></span> #{text}"
    else
      "<span class=\"glyphicon glyphicon-#{name}\"></span>"
    end.html_safe
  end

  def svg_tag(path, options = {})
    content_tag(:object, '', { data: path, type: 'image/svg+xml' }.merge(options)).html_safe
  end

  def link_to_modal(name, url, target, html_options = {})
    name = raw '<span class="bos bos-cancel"></span>' if name == :cancel_icon
    name = raw '<span class="bos bos-trash"></span>' if name == :trash_icon
    html_options[:class] = [*html_options[:class], 'with-modal'].join(' ')
    html_options.delete(:method)
    html_options[:data] ||= {}
    html_options[:data].merge! url: url, target: target

    link_to(name, target, html_options)
  end

  # @param [Symbol] action
  # @param [String] path
  # @param [Hash] opts
  # @return {String}
  def button_link(action, path, opts={})
    opts = opts.with_indifferent_access
    opts[:class] = *opts[:class]
    opts[:class] << 'btn-default' unless opts[:class].any? { |s| s.match(/btn\-.+/) }
    opts[:class] += button_class(action: action, static: !opts.delete(:dynamic_width))
    opts[:class].uniq!

    i18n = opts.delete(:i18n) || 'helpers.links'
    name = if t("#{ i18n }.#{action}", default: '').empty?
             t(".#{action}")
           else
             t(".#{action}", default: t("#{ i18n }.#{action}"))
           end
    if opts.delete(:with_modal)
      opts.delete(:method)
      opts[:data] ||= {}
      opts[:data].merge!(url: path)
      opts[:data][:target] ||= '#destroy-modal'
      link_to_modal(name, path, '#destroy-modal', opts)
    else
      link_to(name, path, opts)
    end
  end

  def button_class(*args, action:, static: false)
    %W[ btn btn-action-#{action}].push(static ? 'btn-static-width' : '').concat(args).uniq
  end

  #
  # Creates link to current path, with sorting parameters appended, i.e.
  # ?direction=desc&sort=name
  #
  def sortable(column, title = nil)
    title ||= column.titleize
    sorted_column = params.fetch(:sorted, {})[:column]
    sorted_direction = params.fetch(:sorted, {})[:direction]

    css_class = (column == sorted_column) ? "current #{sorted_direction}" : nil
    direction = (column == sorted_column && sorted_direction == "asc") ? "desc" : "asc"

    link_to title, params.merge(sorted: { column: column, direction: direction}), class: css_class
  end

  def walkthrough_data(index, part)
    {
      walkthrough_index:     index,
      walkthrough_highlight: index,
      walkthrough_title:     t("walkthrough.#{part}.title"),
      walkthrough_body:      t("walkthrough.#{part}.body")
    }
  end

  def logo_link_url
    AppConfig.landing_page_url || root_path
  end

  def edit?
    params[:action] == 'edit'
  end

  def new?
    params[:action] == 'new'
  end

  def current_beacon_zone_color
    return 'transparent' unless @beacon
    "##{@beacon.zone.try(:color) || BeaconFilterForm::UNASSIGNED_ZONE.color}"
  end
end
