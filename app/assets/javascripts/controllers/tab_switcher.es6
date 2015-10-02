export class TabSwitcher {
  /**
   * @param {jQuery} el
   */
  constructor(el) {
    this.el = el;
    this.el.data('tab-switcher', this);
    this.currentTab = this.el.find('.tab-space .tab-content:first-child');
    this.el.find('.tab-space .tab-content:not(:first-child)').hide(0);
    this.setEvents();
  }

  setEvents() {
    this.el.on('click', 'a.tab-switcher', (event)=> { this.switchTab(event); });
  }

  /**
   * @param {jQuery.Event} event
   */
  switchTab(event) {
    event.preventDefault();
    const el = this.el.find(event.target);
    const target = this.el.find(el.data('target'));
    if (!this.currentTab)
      this.currentTab = target;
    if (!this.isValid) return;
    el.closest('.tab-space').find('.tab-switcher').removeClass('active');
    el.addClass('active').parent().addClass('active');
    target.closest('.tab-space').find('.tab-content').hide(0);
    target.show(0);
    this.currentTab = target;
    this.propagateEvent(el);
  }

  propagateEvent(el) {
    const all = this.el.find('a.tab-switcher');
    const index = all.index(el);
    let value;
    if (index == 0) value = 'first';
    else if (index+1 == all.length) value = 'last';
    else value = index;
    this.el.attr('value', value);
    this.el.trigger('change', value);
    if (this.el.find('form').length) {
      for (let form of this.el.find('form').toArray()) {
        $(form).trigger('change');
      }
    }
  }

  get isValid() {
    if (!this.currentTab) return true;
    let valid = true;
    this.currentTab.find('input, select, textarea').each((n, el)=> {
      valid = valid && TabSwitcher.validateField(el);
    });
    return valid;
  }

  static validateField(field) {
    const valid = field.checkValidity();
    const el = $(field).closest('.form-group');
    valid ? el.removeClass('error has-error') : el.addClass('error has-error');
    return valid;
  }
}

$(function () {
  const tabManagers = $('.tab-manager');
  tabManagers.each(function () {
    new TabSwitcher($(this));
  });
});