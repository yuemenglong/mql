var Auto = require("./sys/auto");
var execute = require("./sys/execute");
var analyze = require("./sys/analyze");
var _ = require("lodash");

function Strategy(symbol) {
    _.merge(this, new Auto(symbol));
    this.exec = function() {
        var bar = this.bar(0);
        if (bar.ema[6] > bar.ema[18] && !this.autoOpened()) {
            this.autoBuy();
        }
        if (bar.ema[6] < bar.ema[18] && this.autoOpened()) {
            this.autoClose();
        }
    }
}

module.exports = Strategy;

if (require.main == module) {
    var lines = execute(new Strategy("000002"));
    analyze(lines);
}
