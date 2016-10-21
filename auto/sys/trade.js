//openTime, closeTime, open, close, volumn, status
var fs = require("yy-fs");
var resolve = require("./common").resolve;

var INIT = 0;
var OPEN = 1;
var CLOSE = 2;
var DELETE = 3;

function Trade(bars, exec) {
    exec = exec.bind(this);
    var pos = 0;
    var orders = [];
    var order = null;

    this.bar = function(n) {
        n = n || 0;
        var idx = pos - n;
        if (idx < 0) idx = 0;
        if (idx >= bars.length) idx = bars.length - 1;
        return bars[idx];
    }
    this.buy = function(price, volumn) {
        var bar = this.bar(0);
        if (this.opened() || (!price && !bar.volumn)) {
            return;
        }
        price = price || bar.close;
        volumn = volumn || 1;
        order = {
            openTime: bar.time,
            open: price,
            volumn: volumn,
            status: OPEN,
        }
    }
    this.close = function(price, volumn) {
        var bar = this.bar(0);
        if (!this.opened() || (!price && !bar.volumn)) {
            return;
        }
        price = price || bar.close;
        volumn = volumn || 1;
        order.closeTime = bar.time;
        order.close = price;
        order.status = CLOSE;
        orders.push(order);
        order = null;
    }
    this.opened = function() {
        return !!order;
    }
    this.output = function() {
        return orders;
    }
    this.exec = function() {
        bars.map(function(bar, i) {
            pos = i;
            execute(this);
        }.bind(this));
        this.opened() && this.close();
        return this.output();
    }
    this.save = function(symbol) {
        var path = resolve(`${symbol}.trade.csv`);
        var content = this.output().map(o => o.join(",")).join("\n");
        fs.writeFileSync(path, content);
    }

    function execute(that) {
        var bar = that.bar(0);
        var pre = that.bar(1);
        if (that.opened() &&
            (bar.close >= pre.close * 1.2 || bar.close <= pre.close * 0.8)
        ) {
            return that.close(pre.close);
        }
        return exec(bar, pre);
    }
}

module.exports = Trade;
