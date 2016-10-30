var Auto = require("./sys/auto");
var execute = require("./sys/execute");
var stat = require("./sys/analyze").stat;
var print = require("./sys/analyze").print;
var getBars = require("./sys/data-source").getBars;
var getSymbols = require("./sys/data-source").getSymbols;
var getOrigBars = require("./sys/data-source").getOrigBars;
var Promise = require("bluebird");
var Trade = require("./sys/trade");
var updateLog = require("./sys/common").updateLog;
var _ = require("lodash");
var fs = require("yy-fs");
var P = require("path");
var kit = require("./sys/kit");

var INDICATOR = "ma";

//随机抽取进行测试
function strategy() {
    return function(bar, pre) {
        if (bar.close > pre.close) {
            return this.buy();
        } else if (bar.close < pre.close) {
            return this.sell();
        }
    }
}

module.exports = strategy;

if (require.main == module) {
    // var symbol = kit.getSymbol();
    var start = kit.getArgs("-t", 1, "2001");
    var end = kit.getArgs("-t", 2, "2020");
    var n = kit.getArgs("-n", 1);
    var result = [];
    // var result = {};
    return getSymbols().then(function(symbols) {
        if (n) symbols = _.sampleSize(symbols, n);
        return Promise.each(symbols, function(symbol, i) {
            return getOrigBars(symbol).then(function(bars) {
                bars = bars.filter(function(bar) {
                    return start <= bar.time && bar.time <= end;
                })
                var trade = new Trade(bars, strategy());
                var output = trade.exec();
                kit.updateLog(_.floor(i / symbols.length * 100, 2), "%");
                var last = trade.stat().slice(-1)[0];
                if (!last) return;
                var res = last.end;
                result.push({ symbol, res });

                // var stat = trade.stat();
                // if (!stat.length) return;
                // var yearResult = _(stat).groupBy(function(order) {
                //     return order.openTime.slice(0, 4);
                // }).transform(function(res, value, key) {
                //     res[key] = value.reduce((acc, item) => acc * item.end / item.start, 10000);
                //     result[key] = result[key] || [];
                //     result[key].push(res[key]);
                // }, {}).value();
                // console.log(yearResult);
            })
        })
    }).then(function() {
        result = _(result).sortBy("res").reverse().value();
        console.log(result);
        var res = result.reduce((acc, item) => acc + item.res, 0);
        kit.writeArray(result, "result/open-close.txt");

        // result = _.transform(result, function(res, value, key) {
        //     res[key] = _.mean(value);
        // }, {});
        // var res = _.transform(result, function(res, value, key) {
        //     var last = _.floor(res.slice(-1)[0] * value / 10000);
        //     res.push(last);
        // }, [10000]);
        // console.log(result);
        // console.log(res);
        // return result;
    })
}
