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
    this.findTab();
  }

  setEvents() {
    this.el.on('click', 'a.tab-switcher', (event)=> {
      this.switchTab(event);
    });

    this.el.on('validation:error', ()=> { this.findTab(); });
  }

  findTab() {
    for (let tab of this.tabs) {
      tab = $(tab);
      for (let field of this.fieldsFor(tab, true)) {
        if (!TabSwitcher.validateField(field)) {
          tab.click();
          return;
        }
      }
    }
  }

  /**
   * @param {jQuery.Event} event
   */
  switchTab(event) {
    event.preventDefault();
    const el = this.el.find(event.target);
    const target = this.el.find(el.data('target'));
    if (!this.currentTab) {
      this.currentTab = target;
      this.currentTabSwitcher = el;
    }
    if (this.isNextTab(el) && !this.isValid)
      return;
    el.closest('.tab-space').find('.tab-switcher').removeClass('active');
    el.addClass('active').parent().addClass('active');
    target.closest('.tab-space').find('.tab-content').hide(0);
    target.show(0);
    this.currentTab = target;
    this.currentTabSwitcher = el;
    this.propagateEvent(el);
  }

  isNextTab(tab) {
    const all = this.el.find('a.tab-switcher');
    return all.index(tab) > all.index(this.currentTabSwitcher);
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
    this.currentTab.find('input:visible, select:visible, textarea:visible').each((n, el)=> {
      valid = valid && TabSwitcher.validateField(el);
    });
    return valid;
  }

  /**
   * @param {HTMLElement} field
   * @returns {boolean}
   */
  static validateField(field) {
    let valid = true;
    const validator = $(field).data('custom-validator');
    if (validator) {
      valid = validator.validate();
    } else if ($(field).is(':visible')) {
      valid = field.checkValidity();
    }
    return valid;
  }

  get tabs() {
    return this.el.find('a.tab-switcher').toArray();
  }

  fieldsFor(tab, all) {
    const selector = all ? 'input, select, textarea' : 'input:visible, select:visible, textarea:visible';
    const content = this.contentFor(tab);
    return content.find(selector).toArray();
  }

  contentFor(tab) {
    return this.el.find(tab.data('target'));
  }
}

$(function () {
  const tabManagers = $('.tab-manager');
  tabManagers.each(function () {
    new TabSwitcher($(this));
  });
});