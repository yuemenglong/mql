//openTime, closeTime, open, close, volumn, status
var fs = require("yy-fs");
var resolve = require("./common").resolve;
var _ = require("lodash");

var INIT = 0;
var OPEN = 1;
var CLOSE = 2;
var DELETE = 3;

function Trade(bars, exec, opt) {
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
    this.sell = function(price, volumn) {
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
    this.exec = function() {
        opt && opt.init && opt.init.call(this);
        bars.map(function(bar, i) {
            pos = i;
            execute(this);
        }.bind(this));
        opt && opt.deinit && opt.deinit.call(this);
        this.opened() && this.sell();
        return orders;
    }
    this.save = function(symbol) {
        if (!symbol) throw new Error("No Symbol");
        var path = resolve(`${symbol}.trade.csv`);
        var content = orders.map(function(o) {
            return ["openTime", "closeTime", "open", "close", "volumn", "status"].map(function(name) {
                return o[name];
            }).join(",");
        }).join("\n");
        fs.writeFileSync(path, content);
    }

    function execute(that) {
        var bar = that.bar(0);
        var pre = that.bar(1);
        if (that.opened() &&
            (bar.close >= pre.close * 1.2 || bar.close <= pre.close * 0.8)
        ) {
            return that.sell(pre.close);
        }
        return exec(bar, pre);
    }
}

module.exports = Trade;
