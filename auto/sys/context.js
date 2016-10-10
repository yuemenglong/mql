var _ = require("lodash");
var getBars = require("./data-source").getBars;

function Context(symbol) {
    if (!symbol) {
        throw new Error("Must Point A Symbol");
    }
    this._symbol = symbol;
    this._pos = 0;
    this._bars = getBars(symbol);

    this.init = _.noop;
    this.deinit = _.noop;
    this.output = _.noop;
    this.onNewBar = _.noop;

    this.initialize = function() {
        this._pos = 0;
        this.init();
    }
    this.deinitialize = function() {
        this.deinit();
    }
    this.symbol = function() {
        return this._symbol;
    }
    this.bar = function(n) {
        n = n || 0;
        var idx = this._pos - n;
        if (idx < 0) idx = 0;
        if (idx >= this._bars.length) idx = this._bars.length - 1;
        return this._bars[idx];
    }
    this.open = function(n) {
        return this.bar(n).open;
    }
    this.high = function(n) {
        return this.bar(n).high;
    }
    this.low = function(n) {
        return this.bar(n).low;
    }
    this.close = function(n) {
        return this.bar(n).close;
    }
    this.time = function(n) {
        return this.bar(n).time;
    }
    this.hasNext = function() {
        return this._pos < this._bars.length;
    }
    this.next = function() {
        this.onNewBar();
        this._pos++;
    }
}

module.exports = Context;
