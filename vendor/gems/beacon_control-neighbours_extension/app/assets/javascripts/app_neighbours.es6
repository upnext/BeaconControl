import { Neighbours } from '/neighbours/neighbours';
import { InputsManager } from '/neighbours/inputs_manager';
import { Channel } from '/neighbours/channel';
import { MainNeighbour } from '/neighbours/main_neighbour';
import { RemovableNeighbour } from '/neighbours/removable_neighbour';

const NEIGHBOUR_VIEW = Symbol('neighbour view');
const NEIGHBOUR_DISPATCHER = Symbol('neighbour dispatcher');
const NEIGHBOUR_INPUT_MANAGER = Symbol('neighbour inputs manager');

class AppNeighbours {
  constructor() {
    if (typeof Promise != 'function')
      throw new Error('Neighbour extension require Promise for working. Polyfill it please...');
    if (!this.materialize()) return;
    this.initialize();
  }

  /**
   * Prepare space for working
   * @returns {boolean}
   */
  materialize() {
    this.appOwner = document.body.querySelector('[data-application-id]');
    if (!this.appOwner) return false;

    this.appID     = this.appOwner.dataset.applicationId;
    this.viewport  = this.appOwner.querySelector('#neighbours-viewport');
    this.row       = this.appOwner.querySelector('#neighbours-view-row');
    this.list      = this.appOwner.querySelector('#zone-neighbours-list');
    if (!this.row)
      throw new Error('Main element #neighbours-view-row does not exists!');
    if (!this.viewport)
      throw new Error('View root element #neighbours-viewport does not exists!');
    if (!this.list)
      throw new Error('Neighbours list (#zone-neighbours-list) is missing!');

    this[NEIGHBOUR_DISPATCHER] = new Channel(`${location.protocol}//${location.host}/applications/:application_id/zones/:zone_id/zone_neighbours`);
    this[NEIGHBOUR_VIEW] = new Neighbours({
      root: this.viewport,
      app: this
    });
    this.view.height = this.view.width = 560;//this.viewport.offsetWidth;
    this[NEIGHBOUR_INPUT_MANAGER] = new InputsManager({app: this});
    if (!this.inputsManager.valid) {
      console.error('Input manager is invalid!');
      return false;
    }

    return true;
  }

  /**
   * @returns {InputsManager}
   */
  get inputsManager() {
    return this[NEIGHBOUR_INPUT_MANAGER];
  }

  /**
   * @returns {Neighbours}
   */
  get view() {
    return this[NEIGHBOUR_VIEW];
  }

  /**
   * @returns {Channel}
   */
  get dispatcher() {
    return this[NEIGHBOUR_DISPATCHER];
  }

  /**
   * Draw elements
   */
  initialize() {
    this.view.attach();
    this.inputsManager.setInitState();
    this.listenerWindow();
  }

  /**
   * @param {HTMLOptionElement} element
   */
  changeMain(element) {
    this.view.main.label = element.textContent;
    this.view.main.id = element.value;
    this.view.main.color = `#${element.getAttribute('color')}`;
  }

  /**
   * Synchronize elements
   * @returns {Promise}
   */
  sync() {
    return this.dispatcher.trigger(
      'neighbours.sync',
      {
        zone_id: this.view.main.id,
        application_id: this.appID
      }
    );
  }

  /**
   * Add neighbour
   * @param {Node} node
   * @returns {Promise}
   */
  addNeighbour(node) {
    if (!node || !node.value) return;
    let neighbour = new RemovableNeighbour({
      color: `#${node.getAttribute('color')}`,
      label: node.textContent,
      id: node.value,
      manager: this.view.manager,
      parent: this.view.main
    });
    return this.view.add(neighbour);
  }

  /**
   * Update view depends on window size
   */
  listenerWindow() {
    window.addEventListener('resize', ()=> { this.updateView(); });
  }

  updateView() {
    const all = this.view.main.neighbours;
    for (let i = 0, c; c = all[i++]; ) {
      c.recalculatePosition(i, all.length, this.view);
    }
  }

  /**
   * @param {RemovableNeighbour} neighbour
   * @returns {Promise}
   */
  removeNeighbour(neighbour) {
    if (!neighbour) return;
    return this.view.remove(neighbour);
  }
}

document.addEventListener('DOMContentLoaded', function () {
  window.neighbourApp = new AppNeighbours();
});
window.AppNeighbours = AppNeighbours;