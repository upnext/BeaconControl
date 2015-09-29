export class TransmissionPower {
  constructor(dom) {
    this.dom = dom;
    this.dom.data('controller', this);
    this.setupView();
    this.slider = this.dom.data('slider');
    this.selected = this.slider.selectionEl;
    this.picker = this.slider.picker;
    this.sliderChanged();
  }

  setupView() {
    const changed = ()=>{ this.sliderChanged(); };
    this.dom.
      slider().
      on('slide', changed).
      on('slideStop', changed);
  }

  sliderChanged() {
    this.picker.attr('slider-select-value', this.dom.val());
    this.dom.trigger('change');
  }
}

$(function () {
  const el = $('#transmission_power');
  el.length && new TransmissionPower(el);
});