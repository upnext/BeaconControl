export class TabSwitcher {
  /**
   * @param {jQuery} el
   */
  constructor(el) {
    this.el = el;
    this.el.data('tab-switcher', this);
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
    const el = $(event.target);
    const target = $(el.data('target'));
    el.closest('.tab-space').find('.tab-switcher').removeClass('active');
    el.addClass('active').parent().addClass('active');
    target.closest('.tab-space').find('.tab-content').hide(0);
    target.show(0);
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
  }
}

$(function () {
  const tabManagers = $('.tab-manager');
  tabManagers.each(function () {
    new TabSwitcher($(this));
  });
});