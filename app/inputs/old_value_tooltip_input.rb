class OldValueTooltipInput < SimpleForm::Inputs::StringInput
  def config
    beacon.config if beacon?
  end

  def label(_ = nil)
    @builder.label(attribute_name, t("beacons.form.#{ attribute_name }").html_safe + tooltip.html_safe, {})
  end

  def imported?
    beacon ? beacon.imported? : false
  end

  def tooltip
    return '<span style="display:inline">Missing beacon parameter</span>'.html_safe unless beacon?
    if imported? && config_changed?
      <<-EOS
      <div class="tooltip-button-wrapper #{ attribute_name }-tooltip">
       <div class="bos bos-info_dark tooltip-button"
            data-toggle="tooltip"
            data-placement="top"
            title="#{ config_title }">
        </div>
      </div>
      EOS
    else
      ''
    end.html_safe
  end

  def config_changed?
    beacon.config.send("#{ attribute_name }_changed?")
  end

  def beacon
    options.with_indifferent_access[:beacon]
  end

  def beacon?
    beacon.present?
  end

  def options
    super.merge(include_blank: false)
  end

  def input_html_options
    super.merge(value: config_value)
  end

  def config_value
    beacon.config.send(attribute_name)
  end

  def current_value
    config.send(:"current_#{attribute_name}").to_i
  end

  def config_title
    t("beacons.form.old_value_tooltip", current_value: current_value)
  end
end
