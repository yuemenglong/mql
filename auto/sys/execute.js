var Promise = require("bluebird");

module.exports = function(trade) {
    return Promise.try(function() {
        return trade.initialize();
    }).then(function() {
        while (trade.hasNext()) {
            trade.next();
        }
    }).then(function() {
        return trade.deinitialize();
    }).then(function() {
        return trade.output();
    });
}
