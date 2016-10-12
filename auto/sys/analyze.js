var fs = require("fs");
var _ = require("lodash");
var resolveTrade = require("./common").resolveTrade;
var resolve = require("./common").resolve;
var fix = require("./common").fix;

function getNo() {
    return process.argv.slice(-1)[0].match(/\d+/)[0];
}

function ema(data, n) {
    data.map(function(item, i) {
        item.ema = item.ema || {};
        if (i == 0) {
            item.ema[n] = item.close;
        } else {
            item.ema[n] = _.round((2 * item.close + (n - 1) * data[i - 1].ema[n]) / (n + 1), 8);
        }
    });
}

function getRawData() {
    var fileName = "export/" + getNo() + ".export.csv";
    var content = fs.readFileSync(fileName).toString();
    var lines = content.match(/.+/gm);

    var data = lines.map(function(line) {
        var items = line.split(",");
        return {
            time: items[0].split(" ")[0],
            open: items[1],
            high: items[2],
            low: items[3],
            close: items[4],
        }
    })
    ema(data, 108);
    return data;
}

function stat(records) {
    if (!records) {
        console.log("No Order");
        return;
    }

    var acc = 10000;
    var result = records.map(function(record) {
        var openTime = record[0].split(" ")[0];
        var closeTime = record[1].split(" ")[0];
        var open = fix(record[2]);
        var close = fix(record[3]);
        var start = acc;
        acc = Math.floor(acc * close / open);
        var end = acc;
        var profit = fix((end - start) / start * 100);
        // var info = [openTime, closeTime, open, close, start, end, profit].join("\t");
        // console.log(info);
        return { openTime, closeTime, open, close, start, end, profit };
    }).filter(o => !!o);
    return result;
}

function print(result) {
    result.map(function(r) {
        var info = [r.openTime, r.closeTime, r.open, r.close, r.start, r.end, r.profit].join("\t");
        console.log(info);
    })
    var winCount = result.filter(item => item.profit > 0).length;
    console.log("Win Rate", winCount, result.length, winCount / result.length * 100);
    var content = result.map(item => _.values(item).join(",")).join("\n");
    fs.writeFileSync(resolve("stat.csv"), content);
}


exports.stat = stat;
exports.print = print;

// ShellExecuteA(hWnd, "open", "node", "analyze -- 000001.trade.csv", "D:/workspace/nodejs/mql/auto/", 1);
if (require.main == module) {
    var lines = resolveTrade(process.argv.slice(-1)[0]).match(/.+/gm);
    if (!lines) {
        console.log("No Trade Record");
    } else {
        var records = lines.map(line => line.split(","));
        print(stat(records));
    }
    if (process.argv.indexOf("--") >= 0) {
        setTimeout(_.noop, 10000000);
    }
}
