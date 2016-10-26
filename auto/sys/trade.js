//openTime, closeTime, open, close, volumn, status
var fs = require("yy-fs");
var resolve = require("./common").resolve;
var _ = require("lodash");
var fix = require("./common").fix;

var INIT = 0;
var OPEN = 1;
var CLOSE = 2;
var DELETE = 3;

function Trade(bars, cb, opt) {
    cb = cb.bind(this);
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
    this.inNextBar = function(price) {
        var next = this.bar(-1);
        return next.low <= price && price <= next.high;
    }
    this.buy = function(price, opt) {
        var bar = this.bar(0);
        if (this.opened()) {
            return;
        }
        price = price || bar.close;
        var volumn = _.get(opt, "volumn", 1);
        var openTime = _.get(opt, "time", bar.time);
        order = {
            openTime: openTime,
            open: price,
            volumn: volumn,
            status: OPEN,
        }
        return "BUY";
    }
    this.sell = function(price, opt) {
        var bar = this.bar(0);
        if (!this.opened()) {
            return;
        }
        price = price || bar.close;
        var volumn = _.get(opt, "volumn", 1);
        var closeTime = _.get(opt, "time", bar.time);
        order.closeTime = closeTime;
        order.close = price;
        order.status = CLOSE;
        orders.push(order);
        order = null;
        return "SELL";
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
    this.orders = function() {
        return orders;
    }
    this.detail = function() {
        var details = [];
        var next = 0;
        var opened = false;
        bars.reduce(function(acc, bar) {
            bar = {
                time: bar.time,
                open: bar.open,
                high: bar.high,
                low: bar.low,
                close: bar.close,
                volumn: bar.volumn,
            }
            var order = orders[next];
            if (!order || !opened) {
                bar.res = acc;
                var ret = acc;
            } else if (opened) {
                bar.res = _.floor(acc * bar.close / order.open);
                var ret = acc;
            } else {
                var ret = acc;
            }
            if (order && !opened && bar.time >= order.openTime) {
                opened = true;
            } else if (opened && bar.time >= order.closeTime) {
                opened = false;
                next++;
                bar.res = _.floor(acc * order.close / order.open);
                var ret = bar.res;
            }
            details.push(bar);
            return ret;
        }, 10000);
        return details;
    }
    this.stat = function() {
        var acc = 10000;
        var result = orders.map(function(order) {
            var openTime = order.openTime.split(" ")[0];
            var closeTime = order.closeTime.split(" ")[0];
            var open = fix(order.open);
            var close = fix(order.close);
            var start = acc;
            acc = Math.floor(acc * close / open);
            var end = acc;
            var profit = fix((end - start) / start * 100);
            return { openTime, closeTime, open, close, start, end, profit };
        }).filter(o => !!o);
        return result;
    }
    this.operation = function() {
        var pre = bars.slice(-2)[0];
        var bar = bars.slice(-2)[1];
        return cb(bar, pre);
    }

    function execute(that) {
        var bar = that.bar(0);
        var pre = that.bar(1);
        if (that.opened() &&
            (bar.close >= pre.close * 1.2 || bar.close <= pre.close * 0.8)
        ) {
            return that.sell(pre.close, { time: pre.time });
        }
        return cb(bar, pre);
    }
}



module.exports = Trade;
