/**
 * Native browser input element manager.
 */
export class InputsManager {
  /**
   * @param {AppNeighbours} app
   */
  constructor({app}) {
    /**
     * @type {AppNeighbours}
     */
    this.app = app;
    this.findFields();
  }

  /**
   * Mount listeners and set fields default value.
   */
  setInitState() {
    this.setListeners();
    this.initFields();
  }

  /**
   * Lookup for input elements
   */
  findFields() {
    if (!this.app || !this.app.appOwner) return;
    this.available = this.app.appOwner.querySelector('[name="zones"]');
    this.addButton = this.app.appOwner.querySelector('#add-zone-button');
    this.change    = this.app.appOwner.querySelector('[name="change-zone"]');
  }

  /**
   * Mount browser event listeners and subscribe dispatcher.
   */
  setListeners() {
    if (!this.valid) return;
    this.addButton.addEventListener('click', (event)=>{ this.addNeighbour(event); });
    $(this.change).on('change', ()=> { this.setCurrent(); });
    this.app.dispatcher.bind('neighbours.*', (msg)=> { this.updateView(msg); });
  }

  /**
   * Set inputs values.
   */
  initFields() {
    if (!this.valid) return;
    let first;
    first = this.change.querySelector('option:not([value=""])');
    if (first) this.change.value = first.value;
    this.setCurrent();
  }

  /**
   * Add neighbour using current selected in drop-down
   * @param {String} event
   */
  addNeighbour(event) {
    if (event) {
      event.preventDefault();
      event.stopPropagation();
    }
    if (this.selected && this.selected.value != '')
      this.app.
        addNeighbour(this.selected).
        then(()=>{ this.setUnavailable(); }).
        catch(()=>{ this.setUnavailable(); });
  }

  /**
   * Change current selected zone in drop-down and SVG
   * @param {String} id
   */
  setCurrent(id=null) {
    if (id) this.change.value = id;
    let current = this.change.selectedOptions[0];
    if (current.style.display == 'none') {
      let a = [].slice.call(this.change.options, 0);
      for (let i = 0, c; c = a[i++];) {
        if (c.style.display != 'none') {
          current = c;
          break;
        }
      }
    }
    this.app.changeMain(current);
    this.app.sync();
  }

  /**
   * Update SVG and inputs
   * @param {RemovableNeighbour[]} array
   */
  updateView(array) {
    this.app.view.main.neighbours = array;
    this.setUnavailable();
  }

  /**
   * Have all required fields?
   * @returns {boolean}
   */
  get valid() {
    return !!(this.available && this.change && this.addButton);
  }

  /**
   * Current selected option.
   * @returns {HTMLOptionElement}
   */
  get selected() {
    return this.available.selectedOptions[0];
  }

  /**
   * Hide every already added zone.
   */
  setUnavailable() {
    let ids = [], any = false;
    for (let current of this.app.view.main.neighbours)
      ids.push(current.id);
    ids.push(this.app.view.main.id);

    for ( let i = 0, opt, first = true; opt = this.available.options[i++]; ) {
      if (ids.indexOf(String(opt.value)) == -1) {
        opt.style.display = 'block';
        if (first) {
          first = false;
          this.available.value = opt.value;
        }
        any = true;
      } else
        opt.style.display = 'none';
    }
    if (!any) this.available.value = '';
    $(this.available).selectpicker('refresh');
    $(this.change).selectpicker('refresh');
  }
}