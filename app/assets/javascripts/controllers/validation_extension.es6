export const VALIDATOR_TIMEOUT = Symbol('validation timeout');

export class FieldCustomValidator {
  constructor(el) {
    this.el = el;
    this.el.data('custom-validator', this);
    if (!this.el[0].validity) {
      this.el[0].validity = {};
    }
  }

  get isValid() {
    if (!this.shouldValidate())
      return true;
    let valid = this.el[0].checkValidity();
    if (!valid) return false;
    if (this.isRequired && this.isBlank)
      return false;
    if (!this.isValidFormat)
      return false;
    return true;
  }

  validate() {
    const valid = this.isValid;
    const group = this.el.closest('.form-group');
    !valid ?
      group.addClass('error has-error') :
      group.removeClass('error has-error');
    return valid;
  }

  shouldValidate() {
    if (!this.el.data('validate-if') || this.el.data('validate-if') == '')
      return true;
    const [selector, requiredValue] = String(this.el.data('validate-if')).split('=');
    const el = this.el.closest('form').find(selector);
    return el.val() == requiredValue;
  }

  get isRequired() {
    const data = this.el.data('required');
    const attr = this.el.data('required');
    return data == true || attr == 'required' || attr == 'true' || data == 'required' || data == 'true';
  }

  get isBlank() {
    return this.value == '';
  }

  get isValidFormat() {
    if (!this.hasRegExp)
      return true;
    return this.value.match(this.regexp);
  }

  get hasRegExp() {
    return this.pattern.length > 0;
  }

  get regexp() {
    return new RegExp(this.pattern);
  }

  get value() {
    if (this.el.is(':checkbox')) return this.el.is(':checked');
    if (this.el.is('input, select, textarea'))
      return String(this.el.val() || '').trim();
    return String(this.attr('value') || '').trim();
  }

  get pattern() {
    const val = this.el.attr('pattern') || this.el.data('pattern') || '';
    return val.trim();
  }
}

export class ValidationExtension {
  constructor(el) {
    this.el = el;
    this.el.data('validation-extension', this);
    this.mountValidations();
    this.setEvents();
  }

  setEvents() {
    this.el.
      on('submit', (event)=>{ this.validateSubmit(event); }).
      on('keyup', (event)=>{ this.delayedValidate(event); });
  }

  mountValidations() {
    for (let el of this.fields) {
      new FieldCustomValidator($(el));
    }
    this.el.trigger('validation:mounted');
  }

  delayedValidate(event) {
    if(this[VALIDATOR_TIMEOUT])
      clearTimeout(this[VALIDATOR_TIMEOUT]);
    this[VALIDATOR_TIMEOUT] = setTimeout(()=>{
      this.validate(event);
    }, 200);
  }

  validateSubmit(event) {
    let triggered = false;
    this.removeInvalidMarks();
    for (let el of this.fields) {
      el = $(el);
      if (!el.data('custom-validator'))
        continue;
      let validator = el.data('custom-validator');
      const valid = validator.validate();
      if (!valid) {
        event.preventDefault();
        if (!triggered) (triggered = true) && this.el.trigger('validation:error');
      }
    }
    return this.invalidFields;
  }

  removeInvalidMarks() {
    for (let el of this.fields) {
      const group = $(el).closest('.form-group');
      if (group && group.length && group.is('.error, .has-error'))
        group.removeClass('error has-error');
    }
  }

  validate(event, all) {
    let triggered = false;
    this.removeInvalidMarks();
    for (let el of (!all ? this.visibleFields : this.fields)) {
      el = $(el);
      if (!el.data('custom-validator'))
        continue;
      let validator = el.data('custom-validator');
      const valid = validator.validate();
      if (!valid && event && typeof event.preventDefault == 'function') {
        event.preventDefault();
        if (!triggered) (triggered = true) && this.el.trigger('validation:error');
      }
    }
    return this.invalidFields;
  }

  get invalidFields() {
    return this.el.find('.form-group.error').toArray();
  }

  get fields() {
    return this.el.find('input, select, textarea').toArray();
  }

  get visibleFields() {
    return this.el.find('input:visible, select:visible, textarea:visible').toArray();
  }
}

$(function () {
  for (let el of $('.validation-extension').toArray()) {
    new ValidationExtension($(el));
  }
});