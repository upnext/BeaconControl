export class TransmissionPower {
  sliderOptions = {
    tooltip: 'hide',
    ticks: [0,1,2,3,4,5,6,7]
  };

  constructor(dom) {
    this.dom = dom;
    this.dom.data('controller', this);
    this.setupView();
    this.slider = this.dom.data().slider;
    this.selected = $(this.slider.trackSelection);
    this.picker = $(this.slider.sliderElem);
    this.sliderChanged(this.dom.val());
  }

  setupView() {
    const changed = (obj) => {
      let sliderNewValue = obj.value.newValue
      this.sliderChanged(sliderNewValue);
    };

    this.dom.
      slider(this.sliderOptions).
      on('change', changed);
  }

  sliderChanged(sliderNewValue) {
    if (sliderNewValue == 0){
      this.slider.setValue(1, false, true);
      return false;
    }

    this.picker.attr('slider-select-value', sliderNewValue);
    this.dom.parents('.controls').find('.transmission-power-value span').text(sliderNewValue);
  }
}

$(function () {
  const el = $('#transmission_power');
  el.length && new TransmissionPower(el);
});