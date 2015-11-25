'use strict';

/**
 * @class Channel
 * HTTP communication wrapper
 */
class Channel {
  constructor(url) {
    /**
     * @type {String}
     */
    this.baseUrl = url;
    /**
     * @type {{}}
     */
    this.eventMap = {};
  }

  /**
   * Subscribe for event
   * @param {String} event
   * @param {Function} callback
   */
  bind(event, callback) {
    let list = this.eventMap[event] || [];
    list.push(callback);
    this.eventMap[event] = list;
  }

  /**
   * Emit event
   * @param {String} event
   * @param {Object} data
   * @param {Function} success
   * @param {Function} failure
   * @returns {Promise}
   */
  trigger(event, data, success, failure) {
    return new Promise((resolve, failed)=>{
      let query = this.transformToQuery(event, data);
      if (!query) return Channel.exec(failed);
      query.data = data;
      $.ajax(query).then(
        (data)=>{
          this.handleResponse(event, data, success, resolve);
        },
        (jqXHR, textStatus, errorThrown)=> {
          if (jqXHR.status <= 399)
            return this.handleResponse(event, null, success, resolve);
          Channel.exec(failed, errorThrown);
          Channel.exec(failure, errorThrown);
        }
      );
    });
  }

  static exec(fn, ...args) {
    if (typeof fn == 'function')
      fn.apply(null, args);
  }

  /**
   * Create crud request
   * @param {String} event
   * @param {Object} data
   * @returns {{method: String, url: String, context: Channel}}
   */
  transformToQuery(event, data) {
    let query = {
      context: this,
      url: this.baseUrl
    };
    let crud = event.match(/\.(delete|destroy|create|show|index|update|new)$/);
    if (crud) crud = crud[1];
    switch (crud) {
      case 'index':
        query.method = 'get';
        break;
      case 'show':
        query.method = 'get';
        query.url += '/:id';
        break;
      case 'destroy':
      case 'delete':
        query.method = 'delete';
        query.url += '/:id';
        break;
      case 'new':
        query.method = 'get';
        break;
      case 'create':
        query.method = 'post';
        break;
      case 'edit':
        query.method = 'get';
        query.url += '/:id';
        break;
      case 'update':
        query.method = 'put';
        query.url += '/:id';
        break;
      default:
        query.method = 'get';
        query.url += '/' + event.match(/[^\.]+$/)[0];
    }
    for (let key in data) {
      if (data.hasOwnProperty(key))
        query.url = query.url.replace(`:${key}`, data[key]);
    }
    return query;
  }

  /**
   * Process response
   * @param {String} event
   * @param {Object} data
   * @param {Function} callback
   * @param {Function} resolve
   */
  handleResponse(event, data, callback, resolve) {
    data = data || {};
    let result, rule;
    for (let key in this.eventMap) {
      if (!this.eventMap.hasOwnProperty(key)) continue;
      rule = new RegExp(key.replace(/\./g, '\\.').replace(/\*/g, '.*'));
      if (event.match(rule)) {
        for (let cb of (this.eventMap[key] || [])) {
          result = cb(data);
          if (result === false) {
            return Channel.finish(callback, resolve);
          }
        }
      }
    }
    Channel.finish(callback, resolve);
  }

  /**
   * Finish request execution.
   * @public
   * @static
   * @param {Function} callback
   * @param {Function} resolve
   */
  static finish(callback, resolve) {
    Channel.exec(callback);
    Channel.exec(resolve);
  }
}