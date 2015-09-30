/**
 * @class EventPublisher
 * @example
 *   <input class="event-publisher control-group" id="beacon_protocol" name="beacon[protocol]">
 */
export class EventPublisher {
  /**
   * @param {jQuery} el
   */
  constructor(el) {
    this.el = el;
    this.id = `#${el.attr('id')}`;
    this.event = this.el.data('event');
    this.el.
      data('event-publisher', this).
      on('change', ()=> { this.publish(); }).
      on('click', (event)=> { this.resolveClick(event); });
  }

  readValue() {
    if (this.isInput)
      return this.el.is(':checkbox') ?
        this.el.is(':checked') :
        this.el.val();
    else
      return String(this.el.attr('value'));
  }

  get isInput() {
    return this.el.is('input, button, select, textarea');
  }

  publish() {
    $(document).trigger('publish', this);
  }

  resolveClick(event) {
    if (this.el.is('button'))
      this.publish();
    if (this.event === 'stop')
      event.preventDefault();
  }
}

/**
 * @class EventSubscriber
 * @example
 *   <div class="event-subscriber" data-publisher="#beacon_protocol" data-action="show" data-match="iBeacon">
 */
export class EventSubscriber {
  /**
   * @param {jQuery} el
   */
  constructor(el) {
    this.el = el;
    this.publisher = el.data('publisher');
    this.action = el.data('action');
    this.event = el.data('on');
    this.value = el.data('match');
    el.data('event-subscriber', this);
    this.listen();
  }

  listen() {
    $(document).on('publish', (event, publisher)=> {
      if (publisher.id === this.publisher) {
        const match = publisher.readValue() === this.value;
        this.exec(this.action, match);
      }
    });
  }

  exec(action, match) {
    switch (EventSubscriber.resolveAction(action, match)) {
      case 'show':
        return this.el.show(0);
      case 'hide':
        return this.el.hide(0);
      case 'click':
        return this.el.click();
      default:
        console.warn(`Unknown subscriber action: ${action} (match: ${match})`);
    }
  }

  static resolveAction(action, match) {
    switch (action) {
      case 'show':
        return match ? 'show' : 'hide';
      case 'hide':
        return match ? 'hide' : 'show';
      default:
        return action;
    }
  }
}

$(function () {
  const publishers = [];
  $('.event-publisher').each(function () {
    publishers.push(new EventPublisher($(this)));
  });
  $('.event-subscriber').each(function () {
    new EventSubscriber($(this));
  });
  for (let publisher of publishers) {
    const el = publisher.el;
    if (el.is('input, select, textarea, [data-init="true"]'))
      publisher.publish();
  }
});
