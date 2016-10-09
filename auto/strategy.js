var Trade = require("./trade").Trade;
var _ = require("lodash");

function Strategy(symbol) {
    _.merge(this, new Trade(symbol));
    this._order = -1;
    this.onNewBar = function() {
        var bar = this.bar(0);
        if (this._order != -1 && this.close(0) < this.close(1) * 0.8) {
            this.orderClose(this._order, this.close(1));
            this._order = -1;
            return;
        }
        if (bar.ema[6] > bar.ema[18] && this._order == -1) {
            this._order = this.orderBuy();
        }
        if (bar.ema[6] < bar.ema[18] && this._order != -1) {
            this.orderClose(this._order);
            this._order = -1;
        }
    }
    this.deinit = function() {
        this._order != -1 && this.orderClose(this._order);
        this.orderSave();
    }
}

module.exports = Strategy;
