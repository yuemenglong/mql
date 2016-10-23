var Auto = require("./sys/auto");
var execute = require("./sys/execute");
var stat = require("./sys/analyze").stat;
var print = require("./sys/analyze").print;
var getBars = require("./sys/data-source").getBars;
var Trade = require("./sys/trade");
var _ = require("lodash");
var fs = require("yy-fs");
var P = require("path");

//短期均线上穿长期均线
function strategy(short, long, flag) {
    return function(bar, pre) {
        var bar = this.bar(0);
        var pre = this.bar(1);
        // if (flag && flag != 0) {
        //     var trend = bar.ema[flag] > pre.ema[flag];
        // } else {
        //     var trend = true;
        // }
        // var flag = bar.ema[5] > pre.ema[5];
        if (bar.ema[short] > bar.ema[long] && !this.opened()) {
            this.buy();
        }
        if (bar.ema[short] < bar.ema[long] && this.opened()) {
            this.sell();
        }
    }
}

function operation(symbol) {
    return getBars(symbol).then(function(bars) {
        var pre = bars.slice(-2)[0];
        var bar = bars.slice(-2)[1];
        if (pre.ema[short] <= pre.ema[long] && bar.ema[short] > bar.ema[long]) {
            console.log("BUY");
        } else if (pre.ema[short] >= pre.ema[long] && bar.ema[short] < bar.ema[long]) {
            console.log("SELL");
        } else {
            console.log("NONE");
        }
    })
}

module.exports = strategy;

if (require.main == module) {
    var short = process.argv.slice(-3)[0];
    var long = process.argv.slice(-3)[1];
    // var flag = process.argv.slice(-3)[2];
    var re = /\d{1,3}/;
    if (!re.test(short) || !re.test(long)) {
        throw new Error("Invalid Short Or Long Or Flag");
    }
    var symbol = process.argv.slice(-1)[0];
    if (!/\d{6}/.test(symbol)) {
        throw new Error("Unknown Symbol: " + symbol);
    }
    if (process.argv.indexOf("op") > 0) {
        return operation(symbol);
    }
    var start = "2001";
    var end = "2020";
    if (process.argv.indexOf("time") > 0) {
        start = process.argv.slice(-5)[0];
        end = process.argv.slice(-5)[1];
    }
    return getBars(symbol).then(function(bars) {
        bars = bars.filter(function(b) {
            // return b.time > "2016.07.14";
            return start <= b.time && b.time <= end;
        })
        var trade = new Trade(bars, strategy(short, long));
        var output = trade.exec();
        trade.save(symbol);
        print(stat(output));
    });
}
