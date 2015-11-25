import { SVGWrapper } from '/neighbours/svgwrapper';

const NEIGHBOUR_MAIN_ELEMENT = Symbol('neighbour main element');

export class Neighbours extends SVGWrapper {
  /**
   * @param {HTMLElement} el
   * @param {HTMLElement} root
   * @param {AppNeighbours} app
   */
  constructor({el, root, app}) {
    super(el);
    /**
     * @type {HTMLElement}
     */
    this.root    = root || document.body;
    /**
     * @type {ViewManager}
     */
    this.manager = new ViewManager({
      view: this,
      app: app
    });
    /**
     * @type {AppNeighbours}
     */
    this.app = app;
    /**
     * @type {number}
     */
    this.width = 400;
    /**
     * @type {number}
     */
    this.height = 400;
  }

  attach() {
    this.root.appendChild(this.node);
    this.main = new MainNeighbour({
      width: 120,
      height: 120,
      r: 120,
      manager: this.manager
    });
  }

  /**
   * Remove neighbour.
   * @param {RemovableNeighbour} neighbour
   * @returns {Promise}
   */
  add(neighbour) {
    return new Promise((resolve, failed)=> {
      if (this.manager.children.length > 15)
        return failed();
      this.app.dispatcher.trigger(
        'neighbours.create',
        this.buildRequest(neighbour.toJSON()),
        ()=> { resolve(); },
        (msg)=> { console.warn("Could not create neighbour %o", msg); failed(); }
      );
    });
  }

  /**
   * Remove neighbour.
   * @param {RemovableNeighbour} neighbour
   * @returns {Promise}
   */
  remove(neighbour) {
    return new Promise((resolve, failed)=> {
      this.app.dispatcher.trigger(
        'neighbours.destroy',
        this.buildRequest(neighbour.toJSON()),
        ()=> { resolve(); },
        (msg)=> { failed(console.warn("Could not remove neighbour %o", msg)); }
      );
    });
  }

  /**
   * Create default element
   * @returns {SVGGraphicsElement}
   */
  createDefault() {
    return this.createElement('svg');
  }

  /**
   * Return viewport width
   * @returns {Number}
   */
  get width() {
    return this.getAttrAsInt('width');
  }

  /**
   * Set viewport width
   * @param {Number} w
   */
  set width(w) {
    this.setAttr('width', w);
  }

  /**
   * Return viewport height
   * @returns {Number}
   */
  get height() {
    return this.getAttrAsInt('height');
  }

  /**
   * Set viewport height
   * @param {Number} h
   */
  set height(h) {
    this.setAttr('height', h);
  }

  /**
   * @returns {MainNeighbour}
   */
  get main() {
    return this[NEIGHBOUR_MAIN_ELEMENT];
  }

  /**
   * Set main neighbour
   * @param {MainNeighbour} neighbour
   */
  set main(neighbour) {
    if (this[NEIGHBOUR_MAIN_ELEMENT])
      this[NEIGHBOUR_MAIN_ELEMENT].detachFrom(this);
    neighbour.x = this.width / 2;
    neighbour.y = this.height / 2;
    neighbour.r = 120;
    this[NEIGHBOUR_MAIN_ELEMENT] = neighbour;
    if (this[NEIGHBOUR_MAIN_ELEMENT])
      this[NEIGHBOUR_MAIN_ELEMENT].attachTo(this);
  }

  buildRequest(json) {
    json.application_id = this.app.appID;
    json.zone_id = this.main.id;
    json.id = json.zone_id;
    return json;
  }
}

