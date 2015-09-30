const LIVE_SEARCH_TABLE_TIMEOUT = '$__timeout__';

export class LiveSearchTable {
  constructor(el) {
    this.el = el;
    this.el.data('live-search-table', this);
    this.searchField = $(this.el.data('search-input'));
    this.setEvents();
  }

  setEvents() {
    this.searchField.on('keydown', ()=> { this.updateTable(); });
  }

  updateTable() {
    if (LIVE_SEARCH_TABLE_TIMEOUT) {
      clearTimeout(this[LIVE_SEARCH_TABLE_TIMEOUT]);
    }
    this[LIVE_SEARCH_TABLE_TIMEOUT] = setTimeout(()=> {
      this.el.find('tbody tr').each((index, el)=> { this.updateVisibility($(el)); });
    }, 100);
  }

  /**
   * @param {jQuery} row
   */
  updateVisibility(row) {
    const str = String(row.data('search')).toLocaleLowerCase();
    const value = String(this.searchField.val()).toLocaleLowerCase();
    if (value.length == 0) return row.show();

    const regex = new RegExp(value);
    str.match(regex) ?
      row.show(0) :
      row.hide(0);
  }
}

$(function () {
  const all = $('.live-search-table');
  all.each(function (){
    new LiveSearchTable($(this));
  });
});
