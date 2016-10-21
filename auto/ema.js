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

var SHORT_MIN = 1;
var SHORT_MAX = 30;
var LONG_MIN = 1;
var LONG_MAX = 120;

var EMA = "ema";
var EMA_RES = "ema.res";

function log(data) {
    console.log(data);
    return data;
}

function Kit() {
    this.log = function(data) {
        console.log(data);
        return data;
    }
    this.writeFileSync = function(path, arr) {
        var content = arr.map(function(line) {
            return _.values(line).join(",");
        }).join("\n");
        fs.writeFileSync(path, content);
    }
    this.multiReduce = function(field) {
        return function(acc, item) {
            return acc * item[field];
        }
    }
    this.ratioReduce = function(upper, lower) {
        return function(acc, item) {
            return acc * item[upper] / item[lower];
        }
    }
    this.getSymbol = function() {
        var symbol = process.argv.slice(-1)[0];
        if (!/\d{6}/.test(symbol)) {
            throw new Error("Invalid Symbol: " + symbol);
        }
        return symbol;
    }
}

var kit = new Kit();

function runEmaStrategy(symbol, short, long) {
    return getBars(symbol).then(function(bars) {
        return _(bars).groupBy(bar => bar.time.match(/^\d{4}/)[0]).value();
    }).then(function(groups) {
        var recordsList = _.range(2001, 2017).map(function(year) {
            if (!groups[year] || !groups[year].length) {
                return;
            }
            var recorder = new Recorder();
            var bars = groups[year];
            bars.map(function(bar, i) {
                if (recorder.opened() && recorder.isInvalid(bar, bars[i - 1])) {
                    recorder.sell(bars[i - 1]);
                    return;
                }
                if (!recorder.opened() && bar.ema[short] > bar.ema[long]) {
                    recorder.buy(bar);
                } else if (recorder.opened() && bar.ema[short] < bar.ema[long]) {
                    recorder.sell(bar);
                }
            });
            if (recorder.opened()) {
                if (groups[year + 1]) {
                    recorder.sell(groups[year + 1][0])
                } else {
                    recorder.sell(bars.slice(-1)[0])
                }
            }
            return recorder.output().map(function(record) {
                record.symbol = symbol;
                record.year = year;
                record.short = short;
                record.long = long;
                return record;
            })
        }).filter(o => !!o);
        var emaResultList = recordsList.map(function(records) {
            if (!records || !records.length) {
                return;
            }
            var result = records.reduce(function(acc, item) {
                return acc * item.close / item.open;
            }, 1);
            return {
                symbol: records[0].symbol,
                year: records[0].year,
                short: records[0].short,
                long: records[0].long,
                res: result,
            }
        }).filter(o => !!o);
        recordsList = _.flatten(recordsList);
        // console.log(recordsList);
        return getDB(function(db) {
            return db.collection(EMA).insertMany(recordsList).then(function() {
                return db.collection(EMA_RES).insertMany(emaResultList);
            });
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


function getEmaStat(symbol, short, long) {
    return stat(getEmaResult(symbol, short, long));
}

function analyzeByYear(symbol, start, end) {
    return getDB(function(db) {
        return db.collection(EMA_RES).find({ symbol: symbol, year: { $gte: start, $lte: end } }).toArray();
    }).then(function(res) {
        //symbol, short, long, year, res
        var result = _(res).groupBy(o => [o.short, o.long].join("_"))
            .transform(function(res, value, key) {
                var obj = { short: value[0].short, long: value[0].long };
                obj.res = value.reduce((acc, item) => acc * item.res, 1);
                res.push(obj);
            }, []).sortBy("res").reverse().slice(0, 100).value();
        console.log(result);
    });
}

function analyze() {
    var symbol = kit.getSymbol();
    return analyzeByYear(symbol, 2001, 2016);
}

function getResult(symbol, short, long, start, end) {
    return getDB(function(db) {
        return db.collection(EMA_RES).find({ symbol: symbol, short: short, long: long, year: { $gte: start, $lte: end } }).toArray().then(function(res) {
            return res.reduce(kit.multiReduce("res"), 1);
        }).then(function(res) {
            console.log(res);
            return res;
        })
    })
}

function byYear() {
    var start = process.argv.slice(-3)[0];
    var end = process.argv.slice(-3)[1];
    var re = /\d{4}/;
    if (!re.test(start) || !re.test(end)) {
        throw new Error("Invalid Year");
    }
    var symbol = kit.getSymbol();
    return analyzeByYear(symbol, parseInt(start), parseInt(end));
}

function result() {
    var start = process.argv.slice(-5)[2];
    var end = process.argv.slice(-5)[3];
    var re = /\d{4}/;
    if (!re.test(start) || !re.test(end)) {
        throw new Error("Invalid Year");
    }
    var short = process.argv.slice(-5)[0];
    var long = process.argv.slice(-5)[1];
    var re = /\d{1,3}/;
    if (!re.test(short) || !re.test(long)) {
        throw new Error("Invalid Year");
    }
    var symbol = kit.getSymbol();
    return getResult(symbol, parseInt(short), parseInt(long), parseInt(start), parseInt(end));
}

function stable() {
    var symbol = kit.getSymbol();
    return getDB(function(db) {
        return db.collection(EMA_RES).find({ symbol: symbol }).toArray();
    }).then(function(res) {
        var result = _(res).groupBy(o => [o.short, o.long].join("_"))
            .transform(function(res, value, key) {
                var obj = {
                    short: value[0].short,
                    long: value[0].long,
                }
                obj.win = value.reduce(function(acc, item) {
                    return acc + (item.res > 1 ? 1 : 0);
                }, 0);
                res.push(obj);
            }, []).sortBy("win").reverse().slice(0, 100).value();
        console.log(result);
    })

}

function master() {
    var symbol = kit.getSymbol();

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
        return getDB(function(db) {
            return Promise.filter(pairs, function(pair) {
                return db.collection(EMA).count({ symbol: symbol, short: pair[0], long: pair[1] }).then(function(count) {
                    return count == 0;
                })
            })
        }).then(function(pairs) {
            console.log(pairs);
            var cpuNo = os.cpus().length - 1;
            var group = _.ceil(pairs.length / cpuNo);
            var tasksList = _.chunk(pairs, group);
            tasksList.map(function(tasks, i) {
                var args = {
                    symbol: symbol,
                    tasks: tasks,
                    // output: `ema.${i}.txt`,
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
        return runEmaStrategy(symbol, short, long).then(function() {
            console.log(args.idx, i, "/", args.tasks.length, short, long);
        });
    });
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
    if (process.argv.indexOf("year") >= 0) {
        return byYear();
    }
    if (process.argv.indexOf("result") >= 0) {
        return result();
    }
    if (process.argv.indexOf("stable") >= 0) {
        return stable();
    }
}
