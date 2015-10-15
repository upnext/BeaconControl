class BeaconBooleanInput < SimpleForm::Inputs::BooleanInput
  def input(wrapper_options = nil)
    if SimpleForm.boolean_style == :beacon
      build_beacon_checkbox(wrapper_options)
    else
      super(wrapper_options)
    end
  end

  def build_beacon_checkbox(wrapper_options)
    options = input_options.fetch(:input_html, {}).merge(wrapper_options)
    build_tag_from('div', class: 'beacon-wrapper') do
      build_hidden_field_for_checkbox +
        build_tag_from('div', class: 'boolean') do
          label = template.label_tag("#{object_name}[#{@attribute_name}]", class: SimpleForm.boolean_label_class) { inline_label }
          input = build_check_box_without_hidden_field(options)
          input + label
        end
    end
  end

  def build_tag_from(tag, opts)
    "<#{tag} #{ opts.each_pair.map { |attr, val| "#{attr}='#{val}'" }.join(' ') }>#{block_given? ? yield : ''}</#{tag}>".html_safe
  end
end