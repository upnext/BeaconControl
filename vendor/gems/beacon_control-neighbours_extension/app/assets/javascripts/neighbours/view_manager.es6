export class ViewManager {
  /**
   * @param {Neighbours} view
   * @param {AppNeighbours} app
   */
  constructor({view, app}) {
    /**
     * @type {Neighbours}
     */
    this.view = view;
    /**
     * @type {AppNeighbours}
     */
    this.app = app;
    /**
     * @type {RemovableNeighbour[]}
     */
    this.children = [];
  }

  /**
   * @param {Neighbour} neighbour
   */
  attach( neighbour ) {
    if (this.has(neighbour))
      return console.warn('neighbour already attached');
    this.children.push( neighbour );
    this.refresh();
  }

  /**
   * @param {Neighbour} neighbour
   */
  remove( neighbour ) {
    this.children.splice(
      this.indexOf( neighbour ),
      1
    );
    neighbour.detachFrom(this.view);
    this.refresh();
  }

  /**
   * Check neighbour is already attached
   * @param {Neighbour} neighbour
   */
  has(neighbour) {
    for ( let current of this.children ) {
      if (neighbour.id == current.id) return true;
    }
    return false;
  }

  /**
   * Clear neighbour list
   */
  clear() {
    for (let node of [].slice.call(this.view.node.childNodes)) {
      if (node.ownerWrapper instanceof RemovableNeighbour)
        node.ownerWrapper.detachFrom(this.view);
    }
    this.children = [];
  }

  /**
   * Return neighbour index
   * @param {Neighbour} neighbour
   * @returns {Number}
   */
  indexOf(neighbour) {
    return this.children.indexOf(neighbour);
  }

  /**
   * Update zones position
   */
  refresh() {
    for (let neighbour of this.children) {
      neighbour.attachTo(this.view);
      neighbour.recalculatePosition(
        this.indexOf(neighbour),
        this.length,
        this.view
      );
    }
  }

  /**
   * Return number of neighbours
   * @returns {Number}
   */
  get length() {
    return this.children.length;
  }
}