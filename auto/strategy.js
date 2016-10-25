var Auto = require("./sys/auto");
var execute = require("./sys/execute");
var stat = require("./sys/analyze").stat;
var print = require("./sys/analyze").print;
var getBars = require("./sys/data-source").getBars;
var Trade = require("./sys/trade");
var _ = require("lodash");
var fs = require("yy-fs");
var P = require("path");

var INDICATOR = "ma";

//短期均线上穿长期均线
function strategy(short, long, flag) {
    return function(bar, pre) {
        if (flag != null && flag != 0) {
            var trend = bar.close > bar[INDICATOR][flag];
        } else {
            var trend = true;
        }
        if (pre[INDICATOR][short] < pre[INDICATOR][long] &&
            bar[INDICATOR][short] > bar[INDICATOR][long] &&
            // bar[INDICATOR][long] > pre[INDICATOR][long] &&
            trend
        ) {
            return this.buy();
        }
        if (pre[INDICATOR][short] > pre[INDICATOR][long] &&
            bar[INDICATOR][short] < bar[INDICATOR][long]
        ) {
            return this.sell();
        }
    }
}

function operation(symbol, short, long) {
    return getBars(symbol).then(function(bars) {
        var trade = new Trade(bars, strategy(short, long));
        console.log(trade.operation());
    })
}

module.exports = strategy;

if (require.main == module) {
    var args = process.argv.slice(-4);
    var short = args[0];
    var long = args[1];
    var flag = args[2];
    var re = /\d{1,3}/;
    if (!re.test(short) || !re.test(long) || !re.test(flag)) {
        throw new Error("Invalid Short Or Long Or Flag");
    }
    var symbol = process.argv.slice(-1)[0];
    if (!/\d{6}/.test(symbol)) {
        throw new Error("Unknown Symbol: " + symbol);
    }
    if (process.argv.indexOf("op") > 0) {
        return operation(symbol, short, long);
    }
    var start = "2001";
    var end = "2020";
    if (process.argv.indexOf("time") > 0) {
        start = process.argv.slice(-6)[0];
        end = process.argv.slice(-6)[1];
    }
    return getBars(symbol).then(function(bars) {
        bars = bars.filter(function(b) {
            // return b.time > "2016.07.14";
            return start <= b.time && b.time <= end;
        })
        var trade = new Trade(bars, strategy(short, long, flag));
        var output = trade.exec();
        trade.save(symbol);
        var content = trade.stat().map(o => _.values(o).join("\t")).join("\n");
        console.log(content);
        var content = trade.detail().map(bar => [bar.time, bar.close, bar.res].join(",")).join("\n");
        fs.writeFileSync(P.resolve(__dirname, "result/detail.csv"), content);
    });
}
