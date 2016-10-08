var fs = require("fs");
var _ = require("lodash");
var moment = require("moment");

var DATE_BASE = new Date(0).valueOf();

function log(data) {
    console.log(data);
    return data;
}

function getTable() {
    var nums = _.range(0, 10).map(function(i) {
        return [i, i];
    })
    var letters = _.range(0, 26).map(function(i) {
        var a = "a".charCodeAt(0);
        return [String.fromCharCode(a + i), 10 + i];
    })
    var table = _.fromPairs(nums.concat(letters));
    return table;
}

function getRawLines() {
    function getTable() {
        var nums = _.range(0, 10).map(function(i) {
            return [i, i];
        })
        var letters = _.range(0, 26).map(function(i) {
            var a = "a".charCodeAt(0);
            return [String.fromCharCode(a + i), 10 + i];
        })
        return _.fromPairs(nums.concat(letters));
    }

    var table = getTable();

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
                acc += table[c];
                return acc;
            }, 0)
        })
    }

    function decodeTime(line) {
        line[0] = moment(DATE_BASE + (line[0] - 3600 * 8) * 1000).format("YYYY.MM.DD HH:mm");
        return line;
    }

    function getDate(line) {
        return line[0].split(" ")[0];
    }

    function getHour(line) {
        return line[0].slice(0, 13);
    }

    function transGroupToList(result, value, key) {
        var date = key;
        var open = value[0][1] / 100;
        var high = _.max(value, "2")[2] / 100;
        var low = _.min(value, "3")[3] / 100;
        var close = value.slice(-1)[0][4] / 100;
        var volumn = _.sumBy(value, "5");
        result.push([date, open, high, low, close, volumn]);
    }


    var lines = fs.readFileSync("000001.2001").toString().match(/.+/gm);
    return _(lines.slice(1))
        .map(decodeLine)
        .filter(_.isObject)
        .map(decodeTime)
        .sortBy("0")
        .groupBy(getDate)
        .transform(transGroupToList, [])
        .value();
}

function getExportLines() {
    var path = __dirname.split("Indicators")[0] + "Files/000002.day.csv";
    return fs.readFileSync(path).toString().match(/.+/gm).map(line => line.split(",").map((item, i) => i < 2 ? item.split(" ")[0] : _.round(item, 2)));
}

function getDisplayData(lines) {
    function toObj(line) {
        return {
            time: line[0],
            open: line[1],
            high: line[2],
            low: line[3],
            close: line[4],
            volumn: line[5]
        };
    }

    function ema(n) {
        return function(acc, item) {
            item.ema = item.ema || {};
            if (!acc) {
                item.ema[n] = item.close;
            } else {
                item.ema[n] = (item.close * 2 + acc * (n - 1)) / (n + 1);
            }
            return item.ema[n];
        }
    }

    function attachEma(lines) {
        lines.reduce(ema(6), 0);
        lines.reduce(ema(18), 0);
        lines.reduce(ema(108), 0);
        return lines;
    }
    return _(lines)
        .map(toObj)
        .thru(attachEma)
        .value();
}

exports.getBars = function() {
    // return getDisplayData(getRawLines());
    return getDisplayData(getExportLines());
}

if (require.main == module) {
    // console.log(getExportLines());
    console.log(getDisplayData(getExportLines()));
}
