var Auto = require("./sys/auto");
var execute = require("./sys/execute");
var stat = require("./sys/analyze").stat;
var print = require("./sys/analyze").print;
var _ = require("lodash");
var P = require("path");
var fs = require("yy-fs");
var cp = require("child_process");


//测试各种ema的情况
function createEmaStrategy(short, long) {
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
    return Strategy;
}

function worker() {
    var json = process.argv.slice(-1)[0];
    var args = JSON.parse(json);
    // console.log(args);
    var result = args.tasks.map(function(task, i) {
        var short = task.short;
        var long = task.long;
        var symbol = args.symbol;

        var Strategy = createEmaStrategy(short, long);
        var records = execute(new Strategy(symbol));
        var result = stat(records);
        var end = result.slice(-1)[0].end;
        console.log(args.idx, i, args.tasks.length, short, long, end);
        return [short, long, end];
    });
    var content = result.map(o => o.join(",")).join("\n");
    fs.writeFileSync(args.output, content);
}

function merge() {
    var res = _.range(0, 8).map(function(i) {
        var fileName = `ema.${i}.txt`;
        var lines = fs.readFileSync(fileName).toString().match(/.+/gm);
        return lines.map(function(line) {
            var items = line.split(",");
            if (items[0] * 2 == items[1]) {
                return ["0,0,0", line];
            } else {
                return line;
            }
        })
    })
    var content = _.flattenDeep(res).join("\n");
    fs.writeFileSync("result/ema.txt", content);
}

function getResultPath(symbol, short, long) {
    return `${__dirname}/ema/${symbol}/${symbol}.${short}-${long}.csv`;
}

function emaResult(symbol, short, long) {
    var path = getResultPath(symbol, short, long);
    try {
        return fs.readFileSync(path).toString().match(/.+/gm).map(l => l.split(","));
    } catch (ex) {
        console.log("calc on real time");
        var Strategy = createEmaStrategy(short, long);
        var records = execute(new Strategy(symbol));
        var content = records.map(r => r.join(",")).join("\n");
        fs.writeFileSync(path, content);
    }
}

function analyze() {
    var lines = fs.readFileSync("result/ema.txt").toString().match(/.+/gm);
    var result = _(lines)
        .map(l => l.split(","))
        .sortBy("2")
        .slice(-100)
        .value();
    console.log(result);
}

if (require.main == module) {
    emaResult("000001", 6, 18);
    // if (process.argv.indexOf("--") >= 0) {
    //     return worker();
    // }
    // if (process.argv.indexOf("merge") >= 0) {
    //     return merge();
    // }
    // if (process.argv.indexOf("analyze") >= 0) {
    //     return analyze();
    // }
    // var symbol = process.argv.slice(-1)[0];
    // if (!/\d{6}/.test(symbol)) {
    //     throw new Error("Unknown Symbol: " + symbol);
    // }
    // var SHORT = 60;
    // var LONG = 120;
    // var result = _.range(1, SHORT).map(function(short) {
    //     return _.range(1, LONG).map(function(long) {
    //         if (short * 2 > long) {
    //             return;
    //         }
    //         if (short * 60 < long) {
    //             return;
    //         }
    //         return { short, long };
    //     }).filter(o => !!o);
    // })
    // result = _.flatten(result);
    // var group = _.ceil(result.length / 8);
    // var tasksList = _.chunk(result, group);
    // tasksList.map(function(tasks, i) {
    //     var args = {
    //         symbol: symbol,
    //         tasks: tasks,
    //         output: `ema.${i}.txt`,
    //         idx: i,
    //     }
    //     args = JSON.stringify(args);
    //     var child = cp.spawn("node", ["ema", "--", args], { stdio: 'inherit' })
    //     child.on("exit", function() {
    //         console.log("Finish " + i);
    //     })
    // });
}
