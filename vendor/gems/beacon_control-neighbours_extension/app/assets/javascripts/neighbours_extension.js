/**
 *= require_self
 *= require guid
 *= require neighbours/utils
 *= require neighbours/channel
 *= require neighbours/svgwrapper
 *= require neighbours/htmlwrapper
 *= require neighbours/remove_button
 *= require neighbours/neighbour
 *= require neighbours/removable_neighbour
 *= require neighbours/main_neighbour
 *= require neighbours/view_manager
 *= require neighbours/neighbours
 *= require neighbours/inputs_manager
 *= require neighbours/animation
 *= require app_neighbours
*/

"use strict";
typeof Symbol == 'function' || (function (){
  window.Symbol = function (s) { return '$__'+s+'__'; };
  function ArrayIterator(target) {
    this.target = target;
    this.value = null;
    this.index = 0;
    this.done = false;
  }
  ArrayIterator.prototype.next = function () {
    this.done = (this.value = this.target[this.index++]) == null;
    return this;
  };
  Symbol.iterator = Symbol('iterator');
  Array.prototype[Symbol.iterator] = Array.prototype[Symbol.iterator] || function () {
    return new ArrayIterator(this);
  };
}());