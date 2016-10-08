var fs = require("fs");
var _ = require("lodash");

function fix(num) {
    num = _.round(num, 2).toString();
    var point = num.split(".")[1];
    if (!point) {
        return num + ".00";
    } else if (point.length == 1) {
        return num + "0";
    } else {
        return num;
    }
}

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

function getContent() {
    var fileName = process.argv.slice(-1)[0];
    if (/\d+/.test(fileName)) {
        fileName += ".trade.csv";
    }
    try {
        return fs.readFileSync(fileName).toString();
    } catch (ex) {
        // C:\MTDriver\MT4\MQL4\Indicators\Test\auto
    }
    console.log(__dirname);
    fileName = __dirname.split("Indicators")[0] + "/Files/" + fileName;
    console.log(fileName);
    try {
        return fs.readFileSync(fileName).toString();
    } catch (ex) {
        throw new Error("Can't Find File: " + fileName);
    }
}

function stat() {
    // var timeMap = getRawData().reduce(function(acc, item) {
    //     acc[item.time] = item;
    //     return acc;
    // }, {});
    var lines = getContent().match(/.+/gm);

    var acc = 10000;
    var hist = lines.map(function(line) {
        var items = line.split(",");
        var openTime = items[0].split(" ")[0];
        var closeTime = items[1].split(" ")[0];
        var time = openTime;
        var open = items[2];
        var close = items[3];
        var start = acc;
        acc = Math.floor(acc * close / open);
        var end = acc;
        var profit = end - start;
        // var ema = timeMap[time].ema[108];
        var info = [openTime, closeTime, fix(open, 2), fix(close, 2), start, end, (end - start) / start * 100,
            // open > ema, end > start
        ].join("\t");
        console.log(info);
        return { time, openTime, closeTime, open, close, start, end, profit };
    }).filter(o => !!o);

    var winCount = hist.filter(item => item.profit > 0).length;
    console.log("Win Rate", winCount, hist.length, winCount / hist.length * 100);

    // var upper = hist.filter(function(item) {
    //     return item.open > timeMap[item.time].ema[108]
    // });
    // var upperWinCount = upper.filter(item => item.profit > 0).length;
    // var upperLossCount = upper.filter(item => item.profit < 0).length;
    // var upperWinAvg = upper.filter(item => item.profit > 0).reduce((acc, item) => acc + item.profit, 0) / upperWinCount;
    // var upperLossAvg = upper.filter(item => item.profit < 0).reduce((acc, item) => acc - item.profit, 0) / upperLossCount;
    // console.log("Upper", upper.length);
    // console.log("Upper Win Rate", upperWinCount, upperWinCount / upper.length * 100);
    // console.log("Upper Win/Loss ", upperWinAvg, upperLossAvg, upperWinAvg / upperLossAvg * 100);

    // var lower = hist.filter(function(item) {
    //     return item.open < timeMap[item.time].ema[108]
    // });
    // var lowerWinCount = lower.filter(item => item.profit > 0).length;
    // var lowerLossCount = lower.filter(item => item.profit < 0).length;
    // var lowerWinAvg = lower.filter(item => item.profit > 0).reduce((acc, item) => acc + item.profit, 0) / lowerWinCount;
    // var lowerLossAvg = lower.filter(item => item.profit < 0).reduce((acc, item) => acc - item.profit, 0) / lowerLossCount;
    // console.log("Lower", lower.length);
    // console.log("Lower Win Rate", lowerWinCount, lowerWinCount / lower.length * 100);
    // console.log("Upper Win/Loss ", lowerWinAvg, lowerLossAvg, lowerWinAvg / lowerLossAvg * 100);
}

function comp() {
    var fileName = process.argv.slice(-1)[0];
    var ema108 = fs.readFileSync(fileName + ".2.txt").toString().match(/.*/mg).map(function(line) {
        var items = line.split(",");
        var time = items[0].split(" ")[0];
        var ema = items.slice(-1)[0];
        return { time: time, ema: ema };
    }).reduce(function(acc, item) {
        acc[item.time] = item;
        return acc;
    }, {});
    // console.log(getRawData());
    var data = getRawData();
    var content = data.map(function(item) {
        var o = ema108[item.time] || {};
        return `${item.time}\t${item.close}\t${item.ema[108]}\t${o.ema}`;
    }).join("\n");
    fs.writeFileSync("a.txt", content);
}

// ShellExecuteA(hWnd, "open", "node", "analyze -- 000001.trade.csv", "D:/workspace/nodejs/mql/auto/", 1);
if (require.main == module) {
    stat();
    if (process.argv.indexOf("--") >= 0) {
        setTimeout(_.noop, 10000000);
    }
}
