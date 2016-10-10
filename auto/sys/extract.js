var fs = require("fs");
var _ = require("lodash");

var cp = require("child_process");
var P = require("path");

var ZIP_PATH = "C:/Program Files/Bandizip/7z/7z";
var RAW = "../raw";
var DIST = "../extract";

function extract() {
    fs.mkdirSync(DIST);

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
            var dest = P.resolve(__dirname, DIST);
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

extract();
