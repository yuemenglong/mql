module.exports = function(trade) {
    trade.initialize();
    while (trade.hasNext()) {
        trade.next();
    }
    trade.deinitialize();
    return trade.output();
}
