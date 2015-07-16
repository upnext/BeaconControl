###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

#
# Wraps <tt>input type=radio</tt> into custom HTML which will look like a button.
#
class CustomRadioButton
  include ActionView::Helpers::TagHelper

  attr_accessor :button, :options

  def initialize(button_obj, options = {})
    self.button  = button_obj
    self.options = options

    build_options
  end

  def to_html
    button.label(label_options) do
      buffer=<<EOS
        #{ button.radio_button.html_safe }
        <span class="custom-button-view">
          <span class="custom-button-name">#{ button.text }</span>
          <span class="custom-button-description">#{ button.object.description }</span>
        </span>
EOS
      buffer.html_safe
    end
  end

  private

  attr_accessor :label_options, :span_options, :radio_button_options

  def build_options
    build_label_options
  end

  def build_label_options
    css_class = Array(label_options.fetch(:class, nil))
    css_class << 'active' if selected?

    label_options[:class] = css_class
  end

  def selected?
    parent.try(:event_type) == button.value ||
      parent.try(:type) == button.value
  end

  def parent
    @parent ||= button.instance_variable_get("@input_html_options")[:object]
  end

  def label_options
    @label_options ||= (options[:label] || {})
  end
end
