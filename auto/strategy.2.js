var Auto = require("./sys/auto");
var execute = require("./sys/execute");
var analyze = require("./sys/analyze");
var _ = require("lodash");

function Strategy(symbol) {
    _.merge(this, new Auto(symbol));
    this.exec = function() {
        var bar = this.bar(0);
        if (bar.dif > bar.dea && !this.autoOpened()) {
            this.autoBuy();
        }
        if (bar.dif < bar.dea && this.autoOpened()) {
            this.autoClose();
        }
    }
}

module.exports = Strategy;

if (require.main == module) {
    var symbol = process.argv.slice(-1)[0];
    if (!/\d{6}/.test(symbol)) {
        throw new Error("Unknown Symbol: " + symbol);
    }
    var records = execute(new Strategy(symbol));
    analyze(records);
}
