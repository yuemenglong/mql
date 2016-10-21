var Auto = require("./sys/auto");
var execute = require("./sys/execute");
var stat = require("./sys/analyze").stat;
var print = require("./sys/analyze").print;
var _ = require("lodash");

var short = 1;
var long = 2;

//短期均线上穿长期均线
function Strategy(symbol) {
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
    var symbol = process.argv.slice(-1)[0];
    if (!/\d{6}/.test(symbol)) {
        throw new Error("Unknown Symbol: " + symbol);
    }
    // var records = execute(new Strategy(symbol));
    // print(stat(records));
    execute(new Strategy(symbol)).then(function(records) {
        print(stat(records));
        var content = records.map(r => r.join(",")).join("\n");
        require("yy-fs").writeFileSync("2.txt", content);
    })
}
