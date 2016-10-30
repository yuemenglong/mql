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

//10个点走人
function strategy(n) {
    n = n || 20;
    var target = 0;
    var ready = true;
    return function(bar, pre) {
        if (target != 0 && bar.high > target) {
            this.sell(target);
            target = 0;
        } else if (ready && bar.close > bar[INDICATOR][n]) {
            this.buy();
            target = bar.close * 1.1;
            ready = false;
        } else if (bar.close < bar[INDICATOR][n]) {
            this.sell();
            target = 0;
            ready = true;
        }
    }
}

module.exports = strategy;

if (require.main == module) {
    var symbol = kit.getSymbol();
    var start = kit.getArgs("-t", 1, "2001");
    var end = kit.getArgs("-t", 2, "2020");
    var n = kit.getArgs("-n", 1, 20);

    getBars(symbol).then(function(bars) {
        bars = bars.filter(function(bar) {
            return "2015.05" <= bar.time;
        })
        var trade = new Trade(bars, strategy());
        trade.exec();
        trade.save(symbol);
        kit.logArray(trade.stat());
    })
}
