var fs = require("yy-fs");
var _ = require("lodash");

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
    this.logArray = function(arr) {
        var content = arr.map(o => _.values(o).join("\t")).join("\n");
        console.log(content);
    }
    this.writeArray = function(arr, path) {
        var content = arr.map(o => _.values(o).join(",")).join("\n");
        fs.writeFileSync(path, content);
    }
    this.updateLog = function() {
        var flag = "\33[K\r";
        var content = _.join(arguments, " ");
        content += flag;
        process.stdout.write(content);
    }
}

var kit = new Kit();

module.exports = kit;
