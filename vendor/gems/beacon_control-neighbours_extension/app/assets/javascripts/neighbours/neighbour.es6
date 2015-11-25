import { SVGWrapper } from '/neighbours/neighbour';

export class Neighbour extends SVGWrapper {
  constructor({color, r, x, y, label, id}) {
    super();
    this.color = color || 'grey';
    this.r = r || 60;
    this.x = x || 0;
    this.y = y || 0;
    this.id = id;
    this.label = label;
    this.uuid = window.guid();
  }

  /**
   * @returns {{neighbour: {name: String, zone_id: String, uuid: String}}}
   */
  toJSON() {
    return {
      neighbour: {
        name: this.label,
        zone_id: this.id,
        uuid: this.uuid
      }
    };
  }

  /**
   * @returns {SVGGraphicsElement}
   */
  createDefault() {
    this.text = this.createElement('text');
    this.circle = this.createElement('circle');
    return this.createElement('g');
  }

  /**
   * @see SVGWrapper#attachTo
   * @param {SVGWrapper} wrapper
   */
  attachTo(wrapper) {
    super.attachTo(wrapper);
    if (this.circle.parentNode != this.node)
      this.node.appendChild(this.circle);
    if (this.text.parentNode != this.node)
      this.node.appendChild(this.text);
    if (this.node.parentNode != wrapper.node)
      wrapper.node.appendChild(this.node);
  }

  /**
   * Calculate position and update it
   * @param {Number} index
   * @param {Number} size
   * @param {Neighbours} view
   */
  recalculatePosition(index, size, view) {
    let part = 360 / size;
    let angle = part * index;
    let radian = (2 * Math.PI / 360) * angle;
    this.r = size > 10 ? 25 : 50;
    this.x = (view.width / 2) + (this.r + view.main.r) * Math.cos(radian);
    this.y = (view.height / 2) + (this.r + view.main.r ) * Math.sin(radian);
    this.updateTextSize(size);
  }

  /**
   * @param {Number} size
   */
  updateTextSize(size) {
    if (size > 10) {
      let label = this.label;
      if (label.length > 8) {
        label = `${label.substr(0, 5)}...`;
      }
      this.text.style.fontSize = '8px';
      this.text.textContent = label;
    } else {
      let label = this.label;
      if (label.length > 11) {
        label = `${label.substr(0, 8)}...`;
      }
      this.text.style.fontSize = '11px';
      this.text.textContent = label;
    }
    this.setTextPosition();
  }

  /**
   * Set neighbour color
   * @param {String} color
   */
  set color(color) {
    this.setAttr('fill', color, this.circle);
    this.setAttr('fill', '#FFF', this.text);
    this.setAttr('fill', color);
  }

  /**
   * @returns {String}
   */
  get color() {
    return this.getAttr('fill');
  }

  /**
   * Set x and update text position
   * @param {Number} x
   */
  set x(x) {
    this.setAttr('x', x);
    this.setAttr('transform', `translate(${ x || 0 }, ${ this.y || 0 })`);
    this.setTextPosition();
  }

  /**
   * @returns {Number}
   */
  get x() {
    return this.getAttrAsInt('x');
  }

  /**
   * Set y and update text position
   * @param {Number} y
   */
  set y(y) {
    //this.setAttr('cy', y, this.circle);
    this.setAttr('y', y);
    this.setAttr('transform', `translate(${ this.x || 0 }, ${ y || 0 })`);
    this.setTextPosition();
  }

  /**
   * @returns {Number}
   */
  get y() {
    return this.getAttrAsInt('y');
  }

  /**
   * Circle radius
   * @param {Number} r
   */
  set r(r) {
    this.setAttr('r', r, this.circle);
    this.setAttr('r', r);
  }

  /**
   * @returns {Number}
   */
  get r() {
    return this.getAttrAsInt('r');
  }

  /**
   * Neighbour name
   * @param {String} v
   */
  set label(v) {
    if (!this.text) return;
    this.__label = String(v);
    this.text.textContent = v;
    this.setTextPosition();
  }

  /**
   * @returns {String}
   */
  get label() {
    if (!this.node) return null;
    return this.__label;
  }

  /**
   * @param {String} v
   */
  set id(v) {
    this.setAttr('id', `neighbour-${v}`);
  }

  /**
   * @returns {String}
   */
  get id() {
    return this.getAttr('id').replace('neighbour-', '');
  }

  get nodeId() {
    return this.getAttr('id');
  }

  /**
   * Set text to center
   * getBBox() returns text actual position and size measured by browser
   * width and height was divided by 2 and 4 but I don't have any idea why
   * in first case it's 2 and second 4
   * Also for Firefox getBBox() throw exception when element is not ready
   * so it's need to be catch and ignore.
   */
  setTextPosition() {
    if (!this.text)
      return console.warn('text element is not attached!');
    try {
      const bbox = this.text.getBBox();
      const x = (-bbox.width / 2) - this.r;
      const y = (bbox.height / 4) - this.r;
      this.setAttr('x', x, this.text);
      this.setAttr('y', y, this.text);
      this.setAttr('dx', `${this.r}px`, this.text);
      this.setAttr('dy', `${this.r}px`, this.text);
    } catch (error) {
    }
  }
}
