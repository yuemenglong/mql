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
        if (flag != 0) {
            var trend = bar.ema[flag] > pre.ema[flag];
        } else {
            var trend = true;
        }
        // var flag = bar.ema[5] > pre.ema[5];
        if (bar.ema[short] > bar.ema[long] && !this.opened() && trend) {
            this.buy();
        }
        if (bar.ema[short] < bar.ema[long] && this.opened()) {
            this.sell();
        }
    }
}

if (require.main == module) {
    var short = process.argv.slice(-4)[0];
    var long = process.argv.slice(-4)[1];
    var flag = process.argv.slice(-4)[2];
    var re = /\d{1,3}/;
    if (!re.test(short) || !re.test(long) || !re.test(flag)) {
        throw new Error("Invalid Short Or Long Or Flag");
    }
    var symbol = process.argv.slice(-1)[0];
    if (!/\d{6}/.test(symbol)) {
        throw new Error("Unknown Symbol: " + symbol);
    }
    getBars(symbol).then(function(bars) {
        var trade = new Trade(bars, strategy(short, long, flag));
        var output = trade.exec();
        trade.save(symbol);
        print(stat(output));
        // var st = stat(output);
        // _(st).groupBy(o => o.openTime.slice(0, 4)).transform(function(res, value, key) {
        //     var obj = {
        //         year: value[0].openTime.slice(0, 4),
        //         res: value.reduce((acc, item) => acc * item.close / item.open, 1),
        //     }
        //     console.log(obj);
        //     res.push(obj);
        // }, []).value();
    });
}
