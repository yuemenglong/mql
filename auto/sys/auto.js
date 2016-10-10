var Trade = require("./trade");
var _ = require("lodash");

function Auto(symbol) {
    _.merge(this, new Trade(symbol));
    this.exec = _.noop;
    this._order = -1;
    this.autoOpened = function() {
        return this._order != -1;
    }
    this.autoBuy = function() {
        if (this.autoOpened()) {
            console.log("Can't Buy");
            return;
        }
        this._order = this.orderBuy();
    }
    this.autoClose = function() {
        if (!this.autoOpened()) {
            console.log("Can't Close");
            return;
        }
        this.orderClose(this._order);
        this._order = -1;
    }
    this.onNewBar = function() {
        var bar = this.bar(0);
        if (this._order != -1 &&
            (this.close(0) < this.close(1) * 0.8 || this.close(0) > this.close(1) * 1.2)
        ) {
            this.orderClose(this._order, this.close(1));
            this._order = -1;
            return;
        }
        this.exec();
        // if (bar.ema[6] > bar.ema[18] && this._order == -1) {
        //     this._order = this.orderBuy();
        // }
        // if (bar.ema[6] < bar.ema[18] && this._order != -1) {
        //     this.orderClose(this._order);
        //     this._order = -1;
        // }
    }
    this.deinit = function() {
        this._order != -1 && this.orderClose(this._order);
        this.orderSave();
    }
}

module.exports = Auto;
