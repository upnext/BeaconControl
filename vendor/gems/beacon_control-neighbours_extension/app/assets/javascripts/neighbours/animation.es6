import { SVGWrapper } from '/neighbours/svgwrapper';
import { Utils } from "/neighbours/utils";

const NEIGHBOUR_ANIMATION_TARGET = Symbol('neighbour animation target');

export class AnimationWrapper {
  constructor({target}) {
    this[NEIGHBOUR_ANIMATION_TARGET] = target;
  }
  static animateMove(opts) {
    return new Promise((resolve) => {
      const animation = new this(opts);
      animation.animate(resolve);
    });
  }
  /**
   * @returns {RemovableNeighbour}
   */
  get target() {
    return this[NEIGHBOUR_ANIMATION_TARGET];
  }
}

export class MoveAnimation extends AnimationWrapper {
  constructor({target, duration, from, to}) {
    super({target: target});
    this.from = from;
    this.to = to;
    this.duration = duration * 1000;
  }

  animate(resolve) {
    if (!this.init)
      this.initialize(resolve);
    requestAnimationFrame(()=>{ this.execMoveStep(resolve); });
  }

  initialize(resolve) {
    this.init = Date.now();
    this.current = 0;
    this.resolve = resolve;
  }

  execMoveStep() {
    const now = Date.now();
    this.current += (now - this.init);
    const {x, y} = this.getPosition(this.currentPart);
    this.target.setAttr('transform', `translate(${x}, ${y})`);
    if (this.current > this.duration)
      return this.resolve();
    this.animate();
  }

  get currentPart() {
    return this.current / this.duration;
  }

  getPosition(part) {
    return {
      x: (this.to.x - this.from.x) * part,
      y: (this.to.y - this.from.y) * part
    };
  }
}

export class MoveByCircleAnimation extends MoveAnimation {
  constructor({target, duration, to, from}) {
    super({target: target, duration: duration, from: from, to: to});
  }

  get currentPart() {
    return (this.to - this.from) * super.currentPart;
  }

  getPosition(part) {
    return Utils.getPositionIn({
      angle: part,
      r: this.target.r,
      main: this.target.manager.app.view.main.r,
      width: this.target.manager.view.width,
      height: this.target.manager.view.height
    });
  }
}