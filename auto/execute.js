var execute = require("./trade").execute;
var Strategy = require("./strategy");
var analyze = require("./analyze");

var lines = execute(new Strategy("000002"));
analyze(lines);
