var Auto = require("./sys/auto");
var execute = require("./sys/execute");
var stat = require("./sys/analyze").stat;
var print = require("./sys/analyze").print;
var _ = require("lodash");
var os = require('os');
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

function getEmaResult(symbol, short, long) {
    var path = getResultPath(symbol, short, long);
    try {
        return fs.readFileSync(path).toString().match(/.+/gm).map(l => l.split(","));
    } catch (ex) {
        var Strategy = createEmaStrategy(short, long);
        var records = execute(new Strategy(symbol));
        var content = records.map(r => r.join(",")).join("\n");
        fs.writeFileSync(path, content);
        return records;
    }
}

function readFileSync(path) {
    return fs.readFileSync(path).toString().match(/.+/gm).map(l => l.split(","));
}

function getSymbol() {
    var symbol = process.argv.slice(-1)[0];
    if (!/\d{6}/.test(symbol)) {
        throw new Error("Invalid Symbol: " + symbol);
    }
    return symbol;
}

function getEmaStat(symbol, short, long) {
    return stat(getEmaResult(symbol, short, long));
}

function analyze() {
    var symbol = getSymbol();
    var dir = P.resolve(__dirname, `ema/${symbol}`);
    var result = fs.readdirSync(dir).map(function(fileName) {
        var path = P.resolve(dir, fileName);
        var match = fileName.match(/\d+\.(\d+)-(\d+).csv/);
        var short = match[1];
        var long = match[2];
        var records = readFileSync(path);
        var result = stat(records);
        var end = result.slice(-1)[0].end;
        return { short, long, end };
    });
    // var lines = fs.readFileSync("result/ema.txt").toString().match(/.+/gm);
    var result = _(result)
        .sortBy("end")
        .reverse()
        // .slice(-100)
        .value();
    console.log(result.slice(0, 100));
    var content = result.map(o => _.values(o).join(",")).join("\n");
    fs.writeFileSync(P.resolve(__dirname, `ema/${symbol}.txt`), content);
}

function master() {
    var symbol = getSymbol();
    var SHORT = 80;
    var LONG = 160;
    var result = _.range(1, SHORT).map(function(short) {
        return _.range(1, LONG).map(function(long) {
            if (short * 2 > long) {
                return;
            }
            if (short * 60 < long) {
                return;
            }
            var path = getResultPath(symbol, short, long);
            try {
                fs.statSync(path);
                return;
            } catch (ex) {
                return { short, long };
            }
        }).filter(o => !!o);
    })
    var cpuNo = os.cpus().length - 1;
    result = _.flatten(result);
    var group = _.ceil(result.length / cpuNo);
    var tasksList = _.chunk(result, group);
    tasksList.map(function(tasks, i) {
        var args = {
            symbol: symbol,
            tasks: tasks,
            output: `ema.${i}.txt`,
            idx: i,
        }
        args = JSON.stringify(args);
        var child = cp.spawn("node", ["ema", "worker", args], { stdio: 'inherit' })
        child.on("exit", function() {
            console.log("Finish " + i);
        })
    });
}

function worker() {
    var json = process.argv.slice(-1)[0];
    var args = JSON.parse(json);
    // console.log(args);
    var result = args.tasks.map(function(task, i) {
        var short = task.short;
        var long = task.long;
        var symbol = args.symbol;

        var result = getEmaStat(symbol, short, long);
        // var Strategy = createEmaStrategy(short, long);
        // var records = execute(new Strategy(symbol));
        // var result = stat(records);
        var end = result.slice(-1)[0].end;
        console.log(args.idx, i, "/", args.tasks.length, short, long, end);
        // return [short, long, end];
    });
    // var content = result.map(o => o.join(",")).join("\n");
    // fs.writeFileSync(args.output, content);
}

if (require.main == module) {
    if (process.argv.indexOf("master") >= 0) {
        return master();
    }
    if (process.argv.indexOf("worker") >= 0) {
        return worker();
    }
    if (process.argv.indexOf("analyze") >= 0) {
        return analyze();
    }
}
