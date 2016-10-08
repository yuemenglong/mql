var _ = require("lodash");
var fs = require("fs");
var getBars = require("./data-source").getBars;

var env = { symbol: "000001" };

var INIT = 0;
var OPEN = 1;
var CLOSE = 2;
var DELETE = 3;

function Context() {
    this._pos = 0;
    this._bars = getBars();

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
        return env.symbol;
    }
    this.bar = function(n) {
        n = n || 0;
        if (n > this._pos) {
            return this._bars[0];
        } else {
            return this._bars[this._pos - n];
        }
    }
    this.next = function() {
        if (this._pos >= this._bars.length) {
            return false;
        }
        this.onNewBar();
        this._pos++;
        return true;
    }
}

function Trade() {
    _.merge(this, new Context());
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
    this.orderClose = function(ticket) {
        if (this._orders.length && this._orders.slice(-1)[0].status != OPEN) {
            console.log("Can't Close");
            return -1;
        }
        this._orders[ticket].closeTime = this.bar(0).time;
        this._orders[ticket].close = this.bar(0).close;
        this._orders[ticket].status = CLOSE;
        return 0;
    }
    this.orderDeleteLast = function() {
        this._orders.pop();
    }
    this.orderSave = function() {
        var fileName = this.symbol() + ".trade.csv";
        var content = this._orders.map(function(o) {
            return [o.openTime, o.closeTime, o.open, o.close, o.volumn, o.status].join(",")
        }).join("\n");
        fs.writeFileSync(fileName, content);
    }
}

function execute(trade) {
    trade.initialize();
    while (trade.next()) {}
    trade.deinitialize();
}

exports.Trade = Trade;
exports.execute = execute;