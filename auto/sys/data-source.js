var fs = require("fs");
var _ = require("lodash");
var moment = require("moment");
var P = require("path");
var cp = require("child_process");
var MongoClient = require("mongodb").MongoClient;
var HttpClient = require("yy-http").HttpClient;
var cheerio = require("cheerio");
var Promise = require("bluebird");
var fix = require("./common").fix;

var DATE_BASE = new Date(0).valueOf();
var RAW_DATA_LOC = "H:/A-stock";

var ZIP_PATH = "C:/Program Files/Bandizip/7z/7z";
var RAW = "../raw";
var EXTRACT_DIST = "../extract";
var OUTPUT_DIR = "../stock";
var EXT = ".day.csv";
var URL = "mongodb://localhost:27017/stock";
var BAR_DAY = "bar.day";
var CACHE_DAY = "cache.day";
var SINA_LAST = "sina.last";

function log(data) {
    console.log(data);
    fs.writeFileSync("./log.txt", JSON.stringify(data, null, "  "));
    return data;
}

function extract() {
    fs.mkdirSync(EXTRACT_DIST);

    var works = fs.readdirSync(RAW).map(function(dir) {
        var dirPath = P.resolve(RAW, dir);
        var stat = fs.statSync(dirPath);
        if (!stat.isDirectory()) {
            return;
        }
        return fs.readdirSync(dirPath).map(function(fileName) {
            if (fileName.slice(-3) != ".cz") {
                return;
            }
            var src = P.resolve(dirPath, fileName);
            var dest = P.resolve(__dirname, EXTRACT_DIST);
            return function() {
                console.log(src, dest);
                var child = cp.spawnSync(ZIP_PATH, ["e", src], { cwd: dest });
            }
        }).filter(o => !!o);
    }).filter(o => !!o);
    works = _.flatten(works);

    works.map(function(fn, i) {
        console.log(i, works.length);
        fn();
    })
}

function merge() {
    var stockMap = getStockMap();

    function getStockMap() {
        return _.chain(fs.readdirSync(EXTRACT_DIST)).reduce(function(acc, fileName) {
            if (!/^\d{6}\./.test(fileName)) {
                return acc;
            }
            var stock = fileName.split(".")[0];
            acc[stock] = acc[stock] || [];
            acc[stock].push(P.resolve(EXTRACT_DIST, fileName));
            return acc;
        }, {}).transform(function(result, value, key) {
            result[key] = value.sort();
        }, {}).value();
    }

    function getCharTable() {
        var nums = _.range(0, 10).map(function(i) {
            return [i, i];
        })
        var letters = _.range(0, 26).map(function(i) {
            var a = "a".charCodeAt(0);
            return [String.fromCharCode(a + i), 10 + i];
        })
        return _.fromPairs(nums.concat(letters));
    }
    var charTable = getCharTable();

    function mergeRawLines(stock) {
        var files = stockMap[stock];
        return _(files).map(function(file) {
            return fs.readFileSync(file).toString().match(/.+/gm);
        }).flatten();
    }

    function decodeLine(line) {
        var items = line.split(",");
        if (items.length != 6) {
            console.log(line);
            return;
        }
        var ret = {};
        return items.map(function(item) {
            return _.reduce(item, function(acc, c) {
                acc *= 36;
                acc += charTable[c];
                return acc;
            }, 0)
        })
    }

    function decodeTime(record) {
        record[0] = moment(DATE_BASE + (record[0] - 3600 * 8) * 1000).format("YYYY.MM.DD HH:mm");
        return record;
    }

    function getDate(record) {
        return record[0].split(" ")[0];
    }

    function getHour(record) {
        return record[0].slice(0, 13);
    }

    function transGroupToRecord(result, value, key) {
        var date = key;
        var all = _(value).map(r => [r[1], r[2], r[3], r[4]]).flatten().value();
        var open = fix(value[0][1] / 100);
        var high = fix(_.max(all) / 100);
        var low = fix(_.min(all) / 100);
        var close = fix(value.slice(-1)[0][4] / 100);
        var volumn = _.sumBy(value, "5") / 100;
        result.push([date, open, high, low, close, volumn]);
    }

    function transFile(file) {
        return _(fs.readFileSync(file).toString().match(/.+/gm))
            .map(decodeLine)
            .filter(_.isObject)
            .map(decodeTime)
            .sortBy("0")
            .groupBy(getDate)
            .transform(transGroupToRecord, [])
            .value();
    }

    function transStock(stock, i) {
        console.log(stock, i, _.keys(stockMap).length);
        return _(stockMap[stock])
            .map(transFile)
            .flatten()
            .thru(writeToFile(stock))
            .value();
    }

    function writeToFile(stock) {
        return function(records) {
            var filePath = P.resolve(__dirname, OUTPUT_DIR, stock + EXT);
            var content = records.map(r => r.join(",")).join("\n");
            fs.writeFileSync(filePath, content);
        }
    }

    // return transFile(stockMap["000001"].slice(-1)[0]);
    // return transStock("000001");
    // return _.keys(stockMap).slice(0, 1).map(transStock);
    return _.keys(stockMap).sort().map(transStock);
}

function Import() {
    var symbol = getSymbol();
    var importPath = __dirname.split("MT4")[0] + "import";

    function rmdir(root) {
        fs.readdirSync(root).map(function(fileName) {
            var path = P.resolve(root, fileName);
            var stat = fs.statSync(path);
            if (stat.isDirectory()) {
                rmdir(path);
                fs.rmdirSync(path);
            } else {
                fs.unlinkSync(path);
            }
        })
    }

    function scanAndCopy(root) {
        fs.readdirSync(root).map(function(fileName) {
            var path = P.resolve(root, fileName);
            var stat = fs.statSync(path);
            if (stat.isDirectory()) {
                scanAndCopy(path);
            } else if (fileName.slice(0, 6) == symbol && /\.cz/.test(fileName)) {
                var dest = P.resolve(importPath, fileName);
                var content = fs.readFileSync(path);
                fs.writeFileSync(dest, content);
                console.log(path, dest);
            }
        })
    }
    rmdir(importPath);
    scanAndCopy(P.resolve(__dirname, RAW));
}

function importToMongo() {
    var db = null;
    var collection = null;

    function singleFile(name) {
        var path = P.resolve(__dirname, "../stock", name);
        var symbol = name.match(/^\d{6}/)[0];
        var records = fs.readFileSync(path).toString().match(/.+/gm).map(function(line) {
            var items = line.split(",");
            return {
                symbol: symbol,
                time: items[0],
                open: items[1],
                high: items[2],
                low: items[3],
                close: items[4],
                volumn: items[5],
            }
        })
        return collection.insertMany(records).then(function(res) {
            console.log(symbol);
        });
    }
    Promise.promisify(MongoClient.connect)(URL).then(function(res) {
        db = Promise.promisifyAll(res);
        collection = db.collection(BAR_DAY);
        return Promise.each(fs.readdirSync(P.resolve(__dirname, "../stock")), singleFile);
    }).catch(function(err) {
        console.log(err.stack);
    }).finally(function() {
        return db.close();
    }).done();
}

var CACHE = {};

function getBars(symbol) {
    function ema(field, n, path) {
        path = path || "ema." + n;
        return function(acc, item) {
            item.ema = item.ema || {};
            if (!acc) {
                var ema = item[field];
            } else {
                var ema = (item[field] * 2 + acc * (n - 1)) / (n + 1);
            }
            ema = _.round(parseFloat(ema), 2);
            _.set(item, path, ema);
            return ema;
        }
    }

    function attachEma(bars) {
        _.range(1, 200).map(function(i) {
            bars.reduce(ema("close", i), 0);
        })
    }

    function attachMacd(bars) {
        bars.map(diff);
        bars.reduce(ema("diff", 9, "dea"), 0);
    }

    function attachMa(bars) {
        _.range(1, 200).map(function(n) {
            bars.reduce(function(acc, bar, i) {
                bar.ma = bar.ma || {};
                if (acc == 0) {
                    acc = bar.close * n;
                } else {
                    var pre = bars[i - n] || bars[0];
                    acc = acc - parseFloat(pre.close) + parseFloat(bar.close);
                }
                bar.ma[n] = _.round(acc / n, 2);
                return acc;
            }, 0);
        })
    }

    function diff(item) {
        item.diff = item.ema[12] - item.ema[26];
    }

    function attachIndicator(bars) {
        attachEma(bars);
        attachMa(bars);
        return bars;
    }
    if (CACHE[symbol]) {
        return Promise.resolve(CACHE[symbol]);
    }
    return getDB(function(db) {
        return db.collection(CACHE_DAY).find({ symbol: symbol }).toArray().then(function(res) {
            if (res && res.length) return res;
            return db.collection(BAR_DAY).find({ symbol: symbol }).toArray().then(function(bars) {
                attachIndicator(bars);
                CACHE[symbol] = bars;
                return db.collection(CACHE_DAY).insertMany(bars).then(function() {
                    return bars;
                })
            });
        })
    })
}

function getSymbols() {
    return getDB(function(db) {
        return db.collection("symbol").find({}).toArray();
    }).then(function(res) {
        return _(res).map(o => o.symbol).sort().value();
    })
}

function getDB(cb) {
    var db = null;
    return Promise.promisify(MongoClient.connect)(URL).then(function(res) {
        db = Promise.promisifyAll(res);
        return cb(db);
    }).finally(function() {
        return db.close();
    })
}

function getSymbol() {
    var symbol = process.argv.slice(-1)[0];
    if (!/\d{6}/.test(symbol)) {
        throw new Error("Invalid Symbol: " + symbol);
    }
    return symbol;
}

function cont() {
    return getDB(function(db) {
        return db.collection("symbol").find({}).toArray().then(function(res) {
            res = _.sortBy(res, "symbol");
            var result = [];
            return Promise.each(res, function(stock) {
                var symbol = stock.symbol;
                return db.collection(BAR_DAY).find({ symbol: symbol }).toArray().then(function(bars) {
                    var continuous = bars.every(function(bar, i) {
                        if (i == 0) return true;
                        if (bar.close < bars[i - 1].close * 0.8 || bar.close > bars[i - 1] * 1.2) {
                            return false;
                        } else {
                            return true;
                        }
                    })
                    if (continuous) {
                        var ret = { symbol: stock.symbol, name: stock.name };
                        console.log(ret);
                        result.push(ret);
                    }
                });
            }).then(function() {
                var content = result.map(o => _.values(o).join(",")).join("\n");
                fs.writeFileSync(P.resolve(__dirname, "../result/cont.txt"), content);
            })
        });
    });
}

function appendFromSina(symbol) {
    // var symbol = getSymbol();

    function getYearAndJidu(lastTime) {
        var date = new Date(lastTime.replace(/\./, "-"));
        var now = new Date();
        if (now.getDay() == 0) now = new Date(now.valueOf() - 86400 * 2 * 1000);
        if (now.getDay() == 6) now = new Date(now.valueOf() - 86400 * 1 * 1000);
        if (date.getFullYear() == now.getFullYear() &&
            date.getMonth() == now.getMonth() &&
            date.getDate() == now.getDate()) {
            console.log(symbol, "Has Last Value");
            return [];
        }
        var days = [];
        date = new Date(date.valueOf() + 86400 * 1000);
        while (date < now) {
            days.push(date);
            date = new Date(date.valueOf() + 86400 * 1000);
        }
        var pairs = _(days).groupBy(function(day) {
            return [day.getFullYear(), _.floor(day.getMonth() / 3) + 1].join("_");
        }).transform(function(res, value, key) {
            var year = key.split("_")[0];
            var jidu = key.split("_")[1];
            res.push({ year, jidu });
        }, []).value();
        return pairs;
    }

    function crawl(pair) {
        var client = new HttpClient();
        var url = "http://vip.stock.finance.sina.com.cn/corp/go.php/vMS_MarketHistory/stockid/{SYMBOL}.phtml?year={YEAR}&jidu={JIDU}";
        url = url.replace("{SYMBOL}", symbol).replace("{YEAR}", pair.year).replace("{JIDU}", pair.jidu);
        console.log("Crawl", url);
        return client.get(url).then(function(res) {
            console.log("Crawl", url, "Succ");
            var $ = cheerio.load(res.body);
            var rows = [];
            $("#FundHoldSharesTable").find("tr").map(function() {
                var row = [];
                $(this).find("td").map(function() {
                    var value = $(this).text().match(/[^\s]+/)[0];
                    row.push(value);
                })
                rows.push(row);
            })
            return rows;
        }).then(function(rows) {
            rows = rows.map(function(r) {
                if (!r.length || !/\d{4}-\d{2}-\d{2}/.test(r)) {
                    return;
                }
                return {
                    symbol: symbol,
                    time: r[0].replace(/-/g, "."),
                    open: r[1],
                    high: r[2],
                    low: r[4],
                    close: r[3],
                    volumn: r[5],
                    src: 1,
                }
            }).filter(o => !!o);
            return rows;
        })
    }

    function getLastTime() {
        return getDB(function(db) {
            return db.collection(SINA_LAST).find({ symbol: symbol }).toArray().then(function(res) {
                if (res && res.length) {
                    return res[0].time;
                }
                return db.collection(BAR_DAY).find({ symbol: symbol }).sort({ time: -1 }).limit(1).toArray().then(function(res) {
                    if (res && res.length) {
                        return res[0].time;
                    }
                    return "2000.12.31";
                });
            })
        })
    }

    return getLastTime().then(function(lastTime) {
        console.log(symbol, lastTime);
        var pairs = getYearAndJidu(lastTime);
        return Promise.mapSeries(pairs, crawl).then(function(res) {
            return _(res).flatten().filter(function(o) {
                return o.time > lastTime;
            }).sortBy("time").value();
        })
    }).then(function(res) {
        if (!res.length) return;
        return getDB(function(db) {
            return db.collection(BAR_DAY).insertMany(res).then(function() {
                return db.collection(SINA_LAST).update({
                    symbol: symbol
                }, {
                    $set: {
                        symbol: symbol,
                        lastTime: moment().format("YYYY.MM.DD"),
                    }
                }, true);
            });
        })
    })
}

function sina() {
    return getSymbols().then(function(symbols) {
        return Promise.each(symbols, function(symbol) {
            return appendFromSina(symbol);
        })
    })
}

function importSymbol() {
    var URL = "http://vip.stock.finance.sina.com.cn/quotes_service/api/json_v2.php/Market_Center.getHQNodeData?page={PAGE}&num=80&sort=symbol&asc=1&node={MARKET}_a&symbol=&_s_r_a=page";
    var client = new HttpClient();
    client.setCharset("gb2312");
    var urls = ["sh", "sz"].map(function(market) {
        return _.range(1, 25).map(function(page) {
            return URL.replace("{MARKET}", market).replace("{PAGE}", page);
        })
    })
    urls = _.flatten(urls);
    return Promise.each(urls, function(url) {
        console.log(url);
        return client.get(url).then(function(res) {
            var json = eval(res.body);
            // var json = JSON.parse(res.body);
            if (!json) return;
            var objs = json.map(function(o) {
                return { symbol: o.code, name: o.name, }
            })
            return getDB(function(db) {
                return db.collection("symbol").insertMany(objs);
            })
        })
    })
}

exports.getBars = getBars;
exports.getDB = getDB;
exports.getSymbols = getSymbols;

if (require.main == module) {
    if (process.argv.indexOf("import") >= 0) {
        Import();
    }
    if (process.argv.indexOf("cont") >= 0) {
        cont();
    }
    if (process.argv.indexOf("sina") >= 0) {
        sina();
    }
    if (process.argv.indexOf("--") >= 0) {
        setTimeout(_.noop, 1000000);
    }
}
