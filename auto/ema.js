var Auto = require("./sys/auto");
var execute = require("./sys/execute");
var stat = require("./sys/analyze").stat;
var print = require("./sys/analyze").print;
var _ = require("lodash");
var os = require('os');
var P = require("path");
var fs = require("yy-fs");
var cp = require("child_process");
var getBars = require("./sys/data-source").getBars;
var getDB = require("./sys/data-source").getDB;
var Recorder = require("./sys/recorder");
var Promise = require("bluebird");

function runEmaStrategy(symbol, short, long) {
    getBars(symbol).then(function(bars) {
        return _(bars).groupBy(bar => bar.time.match(/^\d{4}/)[0]).value();
    }).then(function(groups) {
        var recordsList = _.range(2001, 2017).map(function(year) {
            if (!groups[year] || !groups[year].length) {
                return;
            }
            var recorder = new Recorder();
            recorder = groups[year].reduce(function(recorder, bar) {
                if (!recorder.opened() && bar.ema[short] > bar.ema[long]) {
                    recorder.buy(bar);
                } else if (recorder.opened() && bar.ema[short] < bar.ema[long]) {
                    recorder.sell(bar);
                }
                return recorder;
            }, recorder);
            recorder.opened() && recorder.sell(groups[year].slice(-1)[0]);
            return recorder.output().map(function(record) {
                record.symbol = symbol;
                record.year = year;
                record.short = short;
                record.long = long;
                return record;
            })
        }).filter(o => !!o);
        recordsList = _.flatten(recordsList);
        // console.log(recordsList);
        return getDB(function(db) {
            return db.collection("ema").insertMany(recordsList);
        })
    })
}

//测试各种ema的情况
function createEmaStrategy(short, long) {
    function Strategy(symbol, year) {
        _.merge(this, new Auto(symbol));
        this.init = function() {
            var bars = this.getBars().filter(l => l.time.startWith(symbol.toString()));
        }
        this.exec = function() {
            var bar = this.bar(0);
            var year = parseInt(bar.time.match(/^\d{4}/)[0]);
            if (year > 2010) {
                if (this.autoOpened()) {
                    this.autoClose();
                }
                return;
            }
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
    var SHORT_MIN = 6;
    var SHORT_MAX = 7;
    var LONG_MIN = 18;
    var LONG_MAX = 20;
    return Promise.try(function() {
        var pairs = _.range(SHORT_MIN, SHORT_MAX).map(function(short) {
            return _.range(LONG_MIN, LONG_MAX).map(function(long) {
                if (short * 2 > long) {
                    return;
                }
                if (short * 60 < long) {
                    return;
                }
                return [short, long];
            }).filter(o => !!o);
        })
        pairs = _.flatten(pairs);
        return Promise.filter(pairs, function(pair) {
            return getDB(function(db) {
                return db.collection("ema").count({ symbol: symbol, short: pair[0], long: pair[1] }).then(function(count) {
                    return count == 0;
                })
            });
        }).then(function(pairs) {
            console.log(pairs);
            var cpuNo = os.cpus().length - 1;
            var group = _.ceil(pairs.length / cpuNo);
            var tasksList = _.chunk(pairs, group);
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
            })
        })
    });
}

function worker() {
    var json = process.argv.slice(-1)[0];
    var args = JSON.parse(json);
    return Promise.each(args.tasks, function(task, i) {
        var short = task[0];
        var long = task[1];
        var symbol = args.symbol;

        console.log(args.idx, i, "/", args.tasks.length, short, long);
        return runEmaStrategy(symbol, short, long);
    });
    // console.log(args);
    // var result = args.tasks.map(function(task, i) {
    //     var short = task[0];
    //     var long = task[1];
    //     var symbol = args.symbol;

    //     var result = getEmaStat(symbol, short, long);
    //     // var Strategy = createEmaStrategy(short, long);
    //     // var records = execute(new Strategy(symbol));
    //     // var result = stat(records);
    //     var end = result.slice(-1)[0].end;
    //     console.log(args.idx, i, "/", args.tasks.length, short, long, end);
    //     // return [short, long, end];
    // });
    // var content = result.map(o => o.join(",")).join("\n");
    // fs.writeFileSync(args.output, content);
}

if (require.main == module) {
    // runEmaStrategy("000001", 6, 18);
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
