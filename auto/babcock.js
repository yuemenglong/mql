var Auto = require("./sys/auto");
var execute = require("./sys/execute");
var stat = require("./sys/analyze").stat;
var print = require("./sys/analyze").print;
var getBars = require("./sys/data-source").getBars;
var getWeekBars = require("./sys/data-source").getWeekBars;
var Trade = require("./sys/trade");
var _ = require("lodash");
var fs = require("yy-fs");
var P = require("path");
var kit = require("./sys/kit");

var INDICATOR = "ma";

//超长线
function strategy(short, long) {
    return function(bar) {
        
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
    var symbol = kit.getSymbol();
    var start = kit.getArgs("-t", 1, "2001");
    var end = kit.getArgs("-t", 2, "2020");
    var short = kit.getArgs("-p", 1);
    var long = kit.getArgs("-p", 2);
    var flag = kit.getArgs("-f", 1);
    if (short && long) {
        return getBars(symbol).then(function(bars) {
            bars = bars.filter(function(b) {
                return start <= b.time && b.time <= end;
            })
            var trade = new Trade(bars, strategy(short, long, flag));
            var output = trade.exec();
            trade.save(symbol);
            kit.logArray(trade.stat());
            var bar = bars.slice(-1)[0];
            console.log("Last:", bar.time, bar.close);
            console.log(trade.stat().length);
            kit.writeArray(trade.detail(), "result/detail.csv");
        });
    } else {
        var pairs = _.range(1, 30).map(function(short) {
            return _.range(short * 2, 120).map(function(long) {
                return { short, long };
            })
        })
        pairs = _.flatten(pairs);
        return getBars(symbol).then(function(bars) {
            bars = bars.filter(function(b) {
                return start <= b.time && b.time <= end;
            })
            var result = pairs.map(function(pair, i) {
                var trade = new Trade(bars, strategy(pair.short, pair.long));
                var output = trade.exec();
                kit.updateLog(_.round(i / pairs.length * 100, 2), "%");
                // var res = output.reduce((acc, item) => _.floor(acc * item.close / item.open), 10000);
                var res = trade.stat().slice(-1)[0].end;
                return _.merge({}, pair, { res });
            })
            var result = _(result).sortBy("res").slice(-100).value();
            console.log(result);
        })
    }
}
