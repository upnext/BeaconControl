SimpleForm::FormBuilder.map_type :boolean, to: BeaconBooleanInput

# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  config.wrappers :bootstrap, tag: 'div', class: 'form-group', error_class: 'error has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.use :input
    b.use :error, wrap_with: { tag: 'span', class: 'help-inline' }
    b.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
  end

  config.wrappers :simple, tag: nil do |b|
    b.use :html5
    b.use :placeholder

    b.wrapper :simple_wrapper, tag: nil do |ba|
      ba.use :input
    end
  end

  config.wrappers :simple_with_errors, tag: 'div', class: 'form-group', error_class: 'error has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :input
    b.use :error, wrap_with: { tag: 'span', class: 'help-inline' }
    b.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
  end

  config.wrappers :prepend, tag: 'div', class: "control-group", error_class: 'error has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper tag: 'div', class: 'controls' do |input|
      input.wrapper tag: 'div', class: 'input-prepend' do |prepend|
        prepend.use :input
      end
      input.use :hint,  wrap_with: { tag: 'span', class: 'help-block' }
      input.use :error, wrap_with: { tag: 'span', class: 'help-inline' }
    end
  end

  config.wrappers :append, tag: 'div', class: "control-group", error_class: 'error has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper tag: 'div', class: 'controls' do |input|
      input.wrapper tag: 'div', class: 'input-append' do |append|
        append.use :input
      end
      input.use :hint,  wrap_with: { tag: 'span', class: 'help-block' }
      input.use :error, wrap_with: { tag: 'span', class: 'help-inline' }
    end
  end

  config.wrappers :with_action, tag: 'div', class: 'form-group', error_class: 'error has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper tag: 'div', class: 'input-group' do |input|
      input.use :input
      input.use :hint, wrap_with: { tag: 'span', class: 'input-group-addon btn btn-success add-element' }
    end
    b.use :error, wrap_with: { tag: 'span', class: 'help-inline' }
  end

  #
  config.input_class = 'form-control'

  # Wrappers for forms and inputs using the Twitter Bootstrap toolkit.
  # Check the Bootstrap docs (http://twitter.github.com/bootstrap)
  # to learn about the different styles for forms and inputs,
  # buttons and other elements.
  config.default_wrapper = :bootstrap

  SimpleForm.boolean_style = :beacon
end
