var Trade = require("./trade-context").Trade;
var execute = require("./trade-context").execute;
var _ = require("lodash");

function Stock() {
    _.merge(this, new Trade());
    this._order = -1;
    this.onNewBar = function() {
        var bar = this.bar(0);
        // console.log(bar);
        if (bar.ema[6] > bar.ema[18] && this._order == -1) {
            this._order = this.orderBuy();
        }
        if (bar.ema[6] < bar.ema[18] && this._order != -1) {
            this.orderClose(this._order);
            this._order = -1;
        }
    }
    this.deinit = function() {
        this.orderSave();
    }
}

execute(new Stock());
