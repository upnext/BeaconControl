
export class SVGWrapper {
  constructor(node) {
    /**
     * @type {HTMLElement}
     */
    this.node = node || this.createDefault();
    this.node.ownerWrapper = this;
  }

  createDefault() {}

  //noinspection JSMethodCanBeStatic
  createElement(tag) {
    return document.createElementNS(SVGWrapper.ns, tag)
  }

  /**
   * Attach this element to given wrapper
   * @param {SVGWrapper} wrapper
   */
  attachTo(wrapper) {
    if (this.node.parentNode != wrapper.node)
      wrapper.node.appendChild(this.node);
  }

  /**
   * Detach this element from given wrapper
   * @param {SVGWrapper} wrapper
   */
  detachFrom(wrapper) {
    if (this.node.parentNode == wrapper.node)
      wrapper.node.removeChild(this.node);
  }

  /**
   * @public
   * @static
   * @returns {String}
   */
  static get ns() {
    return "http://www.w3.org/2000/svg";
  }

  /**
   * @public
   * @param {String} name
   * @param {String} value
   * @param {SVGGElement, null} node
   */
  setAttr(name, value, node) {
    let ns = null;
    if (name.match(/:/)) {
      let a = name.split(':');
      name = a.pop();
      ns = a.join(':');
    }
    node = node || this.node;
    if (!node) return;
    node.setAttributeNS(ns, name, value);
  }

  /**
   * @public
   * @param {String} name
   * @param {SVGGElement, null} node
   * @returns {string}
   */
  getAttr(name, node) {
    node = node || this.node;
    if (!node) return;
    return node.getAttribute(name);
  }

  /**
   * @public
   * @param {String} name
   * @param {SVGGElement} node
   * @returns {Number}
   */
  getAttrAsInt(name, node) {
    let v = this.getAttr(name, node);
    v = parseInt(v);
    return isNaN(v) ? null : v;
  }
}