var fs = require("fs");
var _ = require("lodash");

function resolveFileContent(fileName) {
    try {
        return fs.readFileSync(fileName).toString();
    } catch (ex) {
        // C:\MTDriver\MT4\MQL4\Indicators\Test\auto
    }
    fileName = __dirname.split("Indicators")[0] + "/Files/" + fileName;
    try {
        return fs.readFileSync(fileName).toString();
    } catch (ex) {
        throw new Error("Can't Find File: " + fileName);
    }
}

exports.resolveData = function(fileName) {
    if (!/csv$/.test(fileName)) {
        fileName += ".day.csv";
    }
    return resolveFileContent(fileName);
}

exports.resolveTrade = function(fileName) {
    if (!/csv$/.test(fileName)) {
        fileName += ".trade.csv";
    }
    return resolveFileContent(fileName);
}

exports.resolve = function(fileName) {
    fileName = __dirname.split("Indicators")[0] + "/Files/" + fileName;
    return fileName;
}


exports.fix = function(num) {
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
