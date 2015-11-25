import { Neighbour } from '/neighbours/neighbour';
import { MoveByCircleAnimation } from '/neighbours/animation';

const TEMPLATE = Symbol('removable neighbour template');

/**
 * SVG wrapper for main zone neighbours
 */
class RemovableNeighbour extends Neighbour {
  /**
   * @param {String} color
   * @param {Number} r
   * @param {Number} x
   * @param {Number} y
   * @param {String} label
   * @param {Number} id
   * @param {ViewManager} manager
   */
  constructor({color, r, x, y, label, id, manager}) {
    super({color: color, r: r, x: x, y: y, label: label, id: id});
    /**
     * @type ViewManager
     */
    this.manager = manager;
    this.removeButton = new RemoveButton({
      manager: this.manager,
      parent: this
    });
    this.enableSwitching();
  }

  /**
   * Listener for click.
   * After click main neighbour should be changed to this.
   */
  enableSwitching() {
    this.node.addEventListener('click', ()=> { this.changeMain(); });
  }

  /**
   * Set main zone as this.
   */
  changeMain() {
    this.manager.app.inputsManager.setCurrent(this.id);
  }

  /**
   * Attach this element to given wrapper.
   * @param {SVGWrapper} wrapper
   */
  attachTo(wrapper) {
    super.attachTo(wrapper);
    this.removeButton.attachTo(wrapper);

  }

  /**
   * Detach this element from given wrapper
   * @param {SVGWrapper} wrapper
   */
  detachFrom(wrapper) {
    super.detachFrom(wrapper);
    this.removeButton.detachFrom(wrapper);
  }

  /**
   * @deprecated
   * @returns {*[]}
   */
  get nodes() {
    return [this.node, this.text, this.removeButton.node];
  }

  recalculatePosition(index, size, view) {
    MoveByCircleAnimation.animateMove({
      target: this,
      from: 0,
      to: -(360*(index/size)),
      duration: 20
    });
    this.updateTextSize(size);
  }
}