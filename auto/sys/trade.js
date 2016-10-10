var _ = require("lodash");
var fs = require("fs");
var Context = require("./context");
var resolve = require("./common").resolve;
var fix = require("./common").fix;

var INIT = 0;
var OPEN = 1;
var CLOSE = 2;
var DELETE = 3;

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
            open: fix(this.bar(0).close),
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
        this._orders[ticket].close = fix(price);
        this._orders[ticket].status = CLOSE;
        return 0;
    }
    this.orderDeleteLast = function() {
        this._orders.pop();
    }
    this.orderSave = function() {
        var fileName = resolve(this.symbol() + ".trade.csv");
        var content = this.output().map(o => o.join(",")).join("\n");
        fs.writeFileSync(fileName, content);
    }
    this.output = function() {
        return this._orders.map(function(o) {
            return [o.openTime, o.closeTime, o.open, o.close, o.volumn, o.status];
        })
    }
}

module.exports = Trade;
