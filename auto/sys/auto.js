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
        if (this.autoOpened() || this.volumn() == 0) {
            // console.log("Can't Buy");
            return -1;
        }
        this._order = this.orderBuy();
        return 0;
    }
    this.autoClose = function() {
        if (!this.autoOpened() || this.volumn() == 0) {
            // console.log("Can't Close");
            return -1;
        }
        this.orderClose(this._order);
        this._order = -1;
        return 0;
    }
    this.onNewBar = function() {
        var bar = this.bar(0);
        if (this.autoOpened() &&
            (this.close(0) < this.close(1) * 0.8 || this.close(0) > this.close(1) * 1.2)
        ) {
            this.orderClose(this._order, this.close(1));
            this._order = -1;
            return;
        }
        this.exec();
    }
    this.deinit = function() {
        this._order != -1 && this.orderClose(this._order);
        this.orderSave();
    }
}

module.exports = Auto;
