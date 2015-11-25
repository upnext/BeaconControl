const REMOVABLE_BUTTON_TEMPLATE = Symbol('removable button template');

class RemoveButton extends HTMLWrapper {
  /**
   * @param {RemovableNeighbour} parent
   * @param {ViewManager} manager
   */
  constructor({parent, manager}) {
    super();
    /**
     * @type {RemovableNeighbour}
     */
    this.parent = parent;
    /**
     * @type {ViewManager}
     */
    this.manager = manager;
    this.listenEvents();
  }

  createDefault() {
    return document.importNode(
      RemoveButton.TEMPLATE.querySelector('.removable-neighbour-remove'),
      true
    );
  }

  /**
   * Listener for remove click
   */
  listenEvents() {
    this.node.
      querySelector('.remove-neighbour').
      addEventListener('click', ()=>{ this.removeNeighbour(); });
  }

  /**
   * Remove neighbour
   */
  removeNeighbour() {
    this.manager.view.app.removeNeighbour(this.parent);
  }

  /**
   * Update neighbour text and color
   */
  updateView() {
    let name = this.node.querySelector('.neighbour-name');
    name.textContent = this.parent.label;
    name.style.borderLeftColor = this.parent.color;
  }

  /**
   * Attach this element to target wrapper unless attached
   * @param {SVGWrapper} wrapper
   */
  attachTo(wrapper) {
    if (this.node.parentNode != this.manager.app.list)
      this.manager.app.list.appendChild(this.node);
    this.updateView();
  }

  /**
   * Detach this element from given wrapper if attached
   * @param {SVGWrapper} wrapper
   */
  detachFrom(wrapper) {
    if (this.node.parentNode == this.manager.app.list)
      this.manager.app.list.removeChild(this.node);
  }

  /**
   * @static
   * @public
   * @returns {DocumentFragment}
   */
  static get TEMPLATE() {
    if (!this[REMOVABLE_BUTTON_TEMPLATE]) {
      this[REMOVABLE_BUTTON_TEMPLATE] = document.querySelector('#remove-neighbour-row');
      let parent = this[REMOVABLE_BUTTON_TEMPLATE].parentNode;
      parent.removeChild(this[REMOVABLE_BUTTON_TEMPLATE]);
    }
    return this[REMOVABLE_BUTTON_TEMPLATE].content;
  }
}
