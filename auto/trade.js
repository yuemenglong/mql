var _ = require("lodash");
var fs = require("fs");
var getBars = require("./data-source").getBars;
var resolve = require("./common").resolve;

var INIT = 0;
var OPEN = 1;
var CLOSE = 2;
var DELETE = 3;

function Context(symbol) {
    if (!symbol) {
        throw new Error("Must Point A Symbol");
    }
    this._symbol = symbol;
    this._pos = 0;
    this._bars = getBars(symbol);

    this.init = _.noop;
    this.deinit = _.noop;
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

function Trade(symbol) {
    _.merge(this, new Context(symbol));
    this._orders = []; //openTime closeTime open close volumn status
    this.orderBuy = function(volumn) {
        if (this._orders.length && this._orders.slice(-1)[0].status == OPEN) {
            console.log("Can't Buy");
            return -1;
        }
        volumn = volumn || 1;
        return this._orders.push({
            openTime: this.bar(0).time,
            open: this.bar(0).close,
            volumn: volumn,
            status: OPEN,
        }) - 1;
    }
    this.orderClose = function(ticket, price) {
        if (this._orders.length && this._orders.slice(-1)[0].status != OPEN) {
            console.log("Can't Close");
            return -1;
        }
        price = price || this.bar(0).close;
        this._orders[ticket].closeTime = this.bar(0).time;
        this._orders[ticket].close = price;
        this._orders[ticket].status = CLOSE;
        return 0;
    }
    this.orderDeleteLast = function() {
        this._orders.pop();
    }
    this.orderSave = function() {
        var fileName = resolve(this.symbol() + ".trade.csv");
        var content = this.orderOutput().map(o => o.join(",")).join("\n");
        fs.writeFileSync(fileName, content);
    }
    this.orderOutput = function() {
        return this._orders.map(function(o) {
            return [o.openTime, o.closeTime, o.open, o.close, o.volumn, o.status];
        })
    }
}

function execute(trade) {
    trade.initialize();
    while (trade.hasNext()) {
        trade.next();
    }
    trade.deinitialize();
    return trade.orderOutput();
}

exports.Trade = Trade;
exports.execute = execute;
