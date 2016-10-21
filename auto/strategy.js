var Auto = require("./sys/auto");
var execute = require("./sys/execute");
var stat = require("./sys/analyze").stat;
var print = require("./sys/analyze").print;
var _ = require("lodash");
var fs = require("yy-fs");
var P = require("path");

//短期均线上穿长期均线
function Strategy(symbol, short, long) {
    _.merge(this, new Auto(symbol));
    this.exec = function() {
        var bar = this.bar(0);
        if (bar.ema[short] > bar.ema[long] && !this.autoOpened()) {
            this.autoBuy();
        }
        if (bar.ema[short] < bar.ema[long] && this.autoOpened()) {
            this.autoClose();
        }
    }
}

module.exports = Strategy;

if (require.main == module) {
    var short = process.argv.slice(-3)[0];
    var long = process.argv.slice(-3)[1];
    var re = /\d{1,3}/;
    if (!re.test(short) || !re.test(long)) {
        throw new Error("Invalid Short Or Long");
    }
    var symbol = process.argv.slice(-3)[2];
    if (!/\d{6}/.test(symbol)) {
        throw new Error("Unknown Symbol: " + symbol);
    }
    // var records = execute(new Strategy(symbol));
    // print(stat(records));
    execute(new Strategy(symbol, short, long)).then(function(records) {
        print(stat(records));
    })
}
