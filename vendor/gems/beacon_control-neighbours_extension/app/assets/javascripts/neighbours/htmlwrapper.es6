/**
 * HTML Element wrapper
 */
export class HTMLWrapper {
  /**
   * @param {HTMLElement} node
   */
  constructor(node) {
    /**
     * @type {HTMLElement}
     */
    this.node = node || this.createDefault();
    this.node.ownerWrapper = this;
  }

  /**
   * Create default element if non was given
   */
  createDefault() { return null; }

  /**
   * Create html element with given tag
   * @param {String} tag
   * @returns {Element}
   */
  createElement(tag) {
    return document.createElement(tag)
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
   * Set html attribute
   * @param {String} name
   * @param {String|Number|null} value
   * @param {HTMLElement} node
   */
  setAttr(name, value, node) {
    node = node || this.node;
    if (!node) return;
    node.setAttribute(name, value);
  }

  /**
   * Read html attribute
   * @param {String} name
   * @param {HTMLElement} node
   * @returns {string}
   */
  getAttr(name, node) {
    node = node || this.node;
    if (!node) return;
    return node.getAttribute(name);
  }

  /**
   * Read attribute and transform to int
   * @param {String} name
   * @param {HTMLElement} node
   * @returns {Number|null}
   */
  getAttrAsInt(name, node) {
    let v = this.getAttr(name, node);
    v = parseInt(v);
    return isNaN(v) ? null : v;
  }
}