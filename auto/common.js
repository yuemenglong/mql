var fs = require("fs");

function resolve(fileName) {
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
    return resolve(fileName);
}

exports.resolveTrade = function(fileName) {
    if (!/csv$/.test(fileName)) {
        fileName += ".trade.csv";
    }
    return resolve(fileName);
}
