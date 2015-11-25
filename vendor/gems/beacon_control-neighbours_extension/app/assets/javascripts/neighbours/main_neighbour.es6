import { Neighbour } from '/neighbours/neighbour';

const NEIGHBOUR_MAIN_NEIGHBOUR_MANAGER = Symbol('neighbour main neighbour manager');

/**
 * Main SVG circle with description.
 * @class MainNeighbour
 * @extends Neighbour
 */
export class MainNeighbour extends Neighbour {
  /**
   * @param {Number} width
   * @param {Number} height
   * @param {ViewManager} manager
   */
  constructor({width, height, manager}) {
    super({
      width: width,
      height: height
    });
    this[NEIGHBOUR_MAIN_NEIGHBOUR_MANAGER] = manager;
  }

  /**
   * Update view with new list
   * @param {RemovableNeighbour[]} array
   */
  set neighbours(array) {
    this.manager.clear();
    for (let obj of array) {
      obj = this.findOrBuild(obj);
      this.manager.attach(obj);
    }
  }

  /**
   * View manager
   * @returns {ViewManager}
   */
  get manager() {
    return this[NEIGHBOUR_MAIN_NEIGHBOUR_MANAGER];
  }

  /**
   * All available children
   * @returns {RemovableNeighbour[]}
   */
  get neighbours() {
    return this.manager.children;
  }

  /**
   * Lookup DOM for already existing neighbour.
   * @param {String} id
   * @returns {*}
   */
  findInView(id) {
    let el = this.manager.view.node.querySelector(`[id="${id}"]`);
    if (!el) return false;
    return el.ownerWrapper;
  }

  /**
   * Lookup for neighbour or create new.
   * @param {RemovableNeighbour|Object} obj
   * @returns {RemovableNeighbour}
   */
  findOrBuild(obj) {
    if (obj instanceof RemovableNeighbour) return obj;
    let tmp = this.findInView(obj.id);
    if (tmp instanceof RemovableNeighbour) return tmp;
    obj.parent = this;
    obj.manager = this.manager;
    return new RemovableNeighbour(obj);
  }
}