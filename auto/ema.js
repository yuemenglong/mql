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
var getSymbols = require("./sys/data-source").getSymbols;
var getDB = require("./sys/data-source").getDB;
var Trade = require("./sys/trade");
var strategy = require("./strategy");
var Promise = require("bluebird");

var SHORT_MIN = 1;
var SHORT_MAX = 30;
var LONG_MIN = 1;
var LONG_MAX = 120;

var EMA_ORDER = "ema.order"; //symbol short long time
var EMA_RES_YEAR = "ema.res.year"; //symbol short long year
var EMA_RES_LAST = "ema.res.last"; //symbol short long

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
    this.test = function(s, e) {
        if (!e) {
            var pattern = `\\d{${s}}`;
        } else {
            var pattern = `\\d{${s},${e}}`;
        }
        var re = new RegExp(pattern);
        return function(s) {
            if (!re.test(s)) {
                throw new Error(s + " Not Match " + pattern);
            }
        }
    }
    this.getEmaPairs = function() {
        var pairs = _.range(SHORT_MIN, SHORT_MAX).map(function(short) {
            return _.range(LONG_MIN, LONG_MAX).map(function(long) {
                if (short * 2 > long) {
                    return;
                }
                if (short * 60 < long) {
                    return;
                }
                return { short, long };
            }).filter(o => !!o);
        })
        return _.flatten(pairs);
    }
    this.getArgs = function(flag, idx, dft) {
        idx = idx || 1;
        dft = dft || null;
        if (process.argv.indexOf(flag) < 0) {
            return dft;
        } else {
            return process.argv[process.argv.indexOf(flag) + idx];
        }
    }
}

var kit = new Kit();

function runEmaStrategy(symbol, short, long) {
    return getBars(symbol).then(function(bars) {
        return _(bars).groupBy(bar => bar.time.match(/^\d{4}/)[0]).value();
    }).then(function(groups) {
        var ordersList = _.range(2001, 2017).map(function(year) {
            if (!groups[year] || !groups[year].length) {
                return;
            }
            var bars = groups[year];
            var trade = new Trade(bars, function(bar, pre) {
                if (!this.opened() && bar.ema[short] > bar.ema[long]) {
                    this.buy();
                } else if (this.opened() && bar.ema[short] < bar.ema[long]) {
                    this.sell();
                }
            }, {
                deinit: function() {
                    if (!this.opened()) return;
                    if (groups[year + 1]) {
                        this.sell(groups[year + 1][0].close);
                    } else {
                        this.sell(bars.slice(-1)[0].close);
                    }
                }
            })
            return trade.exec().map(function(order) {
                order.symbol = symbol;
                order.year = year;
                order.short = short;
                order.long = long;
                return order;
            })
        }).filter(o => !!o);
        var emaYearResultList = ordersList.map(function(records) {
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
        var orders = _.flatten(ordersList);
        var emaResultLast = {
            symbol: symbol,
            short: short,
            long: long,
            res: emaYearResultList.reduce((acc, item) => acc * item.res, 10000),
        };
        // console.log(ordersList);
        return getDB(function(db) {
            return db.collection(EMA_ORDER).insertMany(orders).then(function() {
                return db.collection(EMA_RES_YEAR).insertMany(emaYearResultList);
            }).then(function() {
                return db.collection(EMA_RES_LAST).insert(emaResultLast);
            });
        })
    })
}

function runEmaTrendStrategy(symbol, short, long) {
    return getBars(symbol).then(function(bars) {
        var result = _.range(long * 2, 120).map(function(flag) {
            var trade = new Trade(bars, strategy(short, long, flag));
            var output = trade.exec();
            var res = output.reduce((acc, item) => acc * item.close / item.open, 1);
            var ret = { short, long, res, flag };
            console.log(ret);
            return ret;
        });
        result = _(result).sortBy("res").value();
        return result;
    });
}

function analyzeByYear(symbol, start, end) {
    return getDB(function(db) {
        return db.collection(EMA_RES_YEAR).find({ symbol: symbol, year: { $gte: start, $lte: end } }).toArray();
    }).then(function(res) {
        //symbol, short, long, year, res
        var result = _(res).groupBy(o => [o.short, o.long].join("_"))
            .transform(function(res, value, key) {
                var obj = { short: value[0].short, long: value[0].long };
                obj.res = value.reduce((acc, item) => acc * item.res, 1);
                res.push(obj);
            }, []).sortBy("res").value();
        return result;
    });
}

function analyzeByTime(symbol, start, end) {
    var pairs = kit.getEmaPairs();
    return getBars(symbol).then(function(bars) {
        bars = bars.filter(function(o) {
            return start <= o.time && o.time <= end;
        })
        return pairs.map(function(pair) {
            var trade = new Trade(bars, strategy(pair.short, pair.long));
            var output = trade.exec();
            var res = output.reduce((acc, item) => acc * item.close / item.open, 10000);
            pair.res = res;
            console.log(pair);
            return pair;
        })
    })
}

//analyze symbol
function analyze() {
    var symbol = kit.getSymbol();
    return analyzeByYear(symbol, 2001, 2016).then(function(res) {
        console.log(res.slice(-100));
    });
}

//year start end symbol
function year() {
    var start = process.argv.slice(-3)[0];
    var end = process.argv.slice(-3)[1];
    var re = /\d{4}/;
    if (!re.test(start) || !re.test(end)) {
        throw new Error("Invalid Year");
    }
    var symbol = kit.getSymbol();
    return analyzeByYear(symbol, parseInt(start), parseInt(end)).then(function(res) {
        console.log(res.slice(-100));
    });;
}

function analyzeTrend(symbol) {
    return analyzeByYear(symbol, 2001, 2016).then(function(res) {
        res = res.slice(-100).map(o => _.set(o, "flag", 0));
        return Promise.mapSeries(res, function(o) {
            return runEmaTrendStrategy(symbol, o.short, o.long);
        }).then(function(res2) {
            return _(res).concat(_.flatten(res2)).sortBy("res").value();
        });
    }).then(function(res) {
        console.log(res.slice(-100));
    });
}

function getResult(symbol, short, long, flag, start, end) {
    return getDB(function(db) {
        return db.collection(EMA_RES_YEAR).find({ symbol: symbol, short: short, long: long, year: { $gte: start, $lte: end } }).toArray().then(function(res) {
            return res.reduce(kit.multiReduce("res"), 1);
        }).then(function(res) {
            console.log(res);
            return res;
        })
    })
}

//result -p short long -f flag -t start end symbol
function result() {
    var short = kit.getArgs("-p", 1);
    var long = kit.getArgs("-p", 2);
    var flag = kit.getArgs("-f");
    var start = kit.getArgs("-t", 1);
    var end = kit.getArgs("-t", 2);
    var symbol = kit.getSymbol();

    function getPairs() {
        if (flag == null) var flags = [null];
        else if (flag == 0) var flags = _.range(1, LONG_MAX);
        else var flags = [flag];
        if (short == null && long == null) {
            var shorts = _.range(1, SHORT_MAX);
            var longs = _.range(1, LONG_MAX);
        } else {
            var shorts = [short];
            var longs = [long];
        }
        var result = flags.map(function(flag) {
            flag = flag == null ? 0 : parseInt(flag);
            return shorts.map(function(short) {
                short = parseInt(short);
                return longs.map(function(long) {
                    long = parseInt(long);
                    if (short * 2 > long) return;
                    if (short * 60 < long) return;
                    if (flag && long * 2 > flag) return;
                    return { short: short, long: long, flag: flag };
                })
            })
        });
        result = _(result).flattenDeep().filter(o => !!o).value();
        return result;
    }

    function timeFilter(bars) {
        if (!start && !end) {
            return bars;
        }
        return bars.filter(function(bar) {
            return start <= bar.time && bar.time <= end;
        })
    }

    return getBars(symbol).then(timeFilter).then(function(bars) {
        var pairs = getPairs();
        return Promise.mapSeries(pairs, function(pair, i) {
            var trade = new Trade(bars, strategy(pair.short, pair.long, pair.flag));
            var output = trade.exec();
            var res = output.reduce((acc, item) => _.floor(acc * item.close / item.open), 10000);
            var ret = { short: pair.short, long: pair.long, flag: pair.flag, res: res };
            var ratio = _.floor(i / pairs.length * 100, 2);
            var out = ratio + "%" + "\33[K\r";
            process.stdout.write(out);
            // console.log();
            return ret;
        });
    }).then(function(res) {
        res = _(res).sortBy("res").slice(-100).value();
        console.log(res);
    })

    // return getResult(symbol, parseInt(short), parseInt(long), parseInt(start), parseInt(end));
}

//stable symbol
function stable() {
    var symbol = kit.getSymbol();
    return getDB(function(db) {
        return db.collection(EMA_RES_YEAR).find({ symbol: symbol }).toArray();
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

function insertOne(symbol) {
    console.log("Start", symbol);
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
                return db.collection(EMA_RES_LAST).count({ symbol: symbol, short: pair[0], long: pair[1] }).then(function(count) {
                    return count == 0;
                })
            })
        }).then(function(pairs) {
            return Promise.each(pairs, function(pair, i) {
                var short = pair[0];
                var long = pair[1];
                return runEmaStrategy(symbol, short, long).then(function() {
                    console.log(i, "/", pairs.length, symbol, short, long);
                });
            })
        })
    });
}

function insert() {
    var symbol = kit.getSymbol();
    return insertOne(symbol);
}

function all() {
    return getSymbols().then(function(symbols) {
        return Promise.each(symbols, insertOne);
    })
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

//symbol
function trend() {
    return analyzeTrend(kit.getSymbol());
}

function time() {
    var start = process.argv.slice(-3)[0];
    var end = process.argv.slice(-3)[1];
    var symbol = kit.getSymbol();
    return analyzeByTime(symbol, start, end).then(function(res) {
        res = _(res).sortBy("res").slice(-100).value();
        console.log(res);
    });
}

if (require.main == module) {
    if (process.argv.indexOf("insert") >= 0) {
        return insert();
    }
    if (process.argv.indexOf("analyze") >= 0) {
        return analyze();
    }
    if (process.argv.indexOf("year") >= 0) {
        return year();
    }
    if (process.argv.indexOf("result") >= 0) {
        return result();
    }
    if (process.argv.indexOf("stable") >= 0) {
        return stable();
    }
    if (process.argv.indexOf("trend") >= 0) {
        return trend();
    }
    if (process.argv.indexOf("time") >= 0) {
        return time();
    }
    if (process.argv.indexOf("all") >= 0) {
        return all();
    }
}
