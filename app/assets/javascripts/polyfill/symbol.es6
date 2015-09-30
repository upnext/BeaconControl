if (typeof Symbol != 'function') {
  let i = 0;
  window.Symbol = function (desc) {
    return `$__${desc}__${i++}__`;
  };
  if (!window.Symbol.iterator) 
    window.Symbol.iterator = Symbol('array iterator');
  if (typeof window.ArrayIterator != 'function') {
    function ArrayIterator(target, n) {
      this.target = target;
      this.n = n;
      this.value = target[n];
      this.done = this.value === undefined;
    }
    ArrayIterator.prototype.next = function () {
      let value = this.target[this.n++];
      return { value: value, done: this.n >= this.target.length };
    };
    window.ArrayIterator = ArrayIterator;
  }
  if (Array.prototype[Symbol.iterator] === undefined) {
    Array.prototype[Symbol.iterator] = function () {
      return new ArrayIterator(this, 0);
    };
  }
} 
