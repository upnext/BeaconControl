class Utils {
  /**
   * @param {Number} index - element index
   * @param {Number} size - collection size
   * @param {Number} r - element radius
   * @param {Number} main - main circle radius
   * @param {Number} width - viewport width
   * @param {Number} height - viewport height
   * @returns {{x: Number, y: Number}}
   */
  static getPositionFor({index, size, r, main, width, height}) {
    const part = 360 / size;
    const angle = part * index;
    const radian = (2 * Math.PI / 360) * angle;
    return {
      x: (width / 2) + (r + main) * Math.cos(radian),
      y: (height / 2) + (r + main) * Math.sin(radian)
    }
  }

  /**
   * @param {Number} angle - degree
   * @param {Number} r - element radius
   * @param {Number} main - main circle radius
   * @param {Number} width - viewport width
   * @param {Number} height - viewport height
   * @returns {{x: Number, y: Number}}
   */
  static getPositionIn({angle, r, main, width, height}) {
    const radian = (2 * Math.PI / 360) * angle;
    return {
      x: (width / 2) + (r + main) * Math.cos(radian),
      y: (height / 2) + (r + main) * Math.sin(radian)
    }
  }
}