var fs = require("fs");
var _ = require("lodash");
var moment = require("moment");
var P = require("path");
var cp = require("child_process");
var fix = require("./common").fix;

var DATE_BASE = new Date(0).valueOf();
var RAW_DATA_LOC = "H:/A-stock";

var ZIP_PATH = "C:/Program Files/Bandizip/7z/7z";
var RAW = "../raw";
var EXTRACT_DIST = "../extract";
var OUTPUT_DIR = "../stock";
var EXT = ".day.csv";

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

function merge() {
    var stockMap = getStockMap();

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
        var volumn = _.sumBy(value, "5");
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

function Import(symbol) {
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

function getDayRecords(symbol) {
    var path = P.resolve(__dirname, `../stock/${symbol}.day.csv`);
    return fs.readFileSync(path).toString().match(/.+/gm).map(line => line.split(",").map((item, i) => i < 2 ? item.split(" ")[0] : _.round(item, 2)));
}

function getBarsFromRecords(records) {
    function toObj(record) {
        return {
            time: record[0],
            open: record[1],
            high: record[2],
            low: record[3],
            close: record[4],
            volumn: record[5]
        };
    }

    function ema(field, n, path) {
        path = path || "ema." + n;
        return function(acc, item) {
            item.ema = item.ema || {};
            if (!acc) {
                var ema = item[field];
                // item.ema[n] = item[field];
            } else {
                var ema = (item[field] * 2 + acc * (n - 1)) / (n + 1);
                // item.ema[n] = (item[field] * 2 + acc * (n - 1)) / (n + 1);
            }
            _.set(item, path, ema);
            return ema;
        }
    }

    function diff(item) {
        item.diff = item.ema[12] - item.ema[26];
    }

    function attachIndicator(records) {
        _.range(1, 200).map(function(i) {
            records.reduce(ema("close", i), 0);
        })
        records.map(diff);
        records.reduce(ema("diff", 9, "dea"), 0);
        return records;
    }
    return _(records)
        .map(toObj)
        .thru(attachIndicator)
        .value();
}

var CACHE = {};

function getBars(symbol) {
    if (!CACHE[symbol]) {
        CACHE[symbol] = getBarsFromRecords(getDayRecords(symbol));
    }
    return CACHE[symbol];
}

exports.getBars = getBars;

if (require.main == module) {
    var symbol = process.argv.slice(-1)[0];
    if (!/\d{6}/.test(symbol)) {
        throw new Error("Invalid Symbol: " + symbol);
    }
    if (process.argv.indexOf("import") >= 0) {
        Import(symbol);
    } else if (process.argv.indexOf("test") >= 0) {
        console.log(getBars(symbol).slice(0, 100));
    } else {
        console.log("Unknown Command");
    }
    if (process.argv.indexOf("--") >= 0) {
        setTimeout(_.noop, 1000000);
    }
}
