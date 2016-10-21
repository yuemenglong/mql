//openTime, closeTime, open, close, volumn, status
var INIT = 0;
var OPEN = 1;
var CLOSE = 2;
var DELETE = 3;

function Recorder() {
    this._order = null;
    this._orders = [];
    this.buy = function(bar, volumn) {
        volumn = volumn || 1;
        if (this._order || !bar.volumn) {
            return;
        }
        this._order = {
            openTime: bar.time,
            open: bar.close,
            volumn: volumn,
            status: OPEN,
        }
    }
    this.sell = function(bar, volumn) {
        volumn = volumn || 1;
        if (!this._order || !bar.volumn) {
            return;
        }
        this._order.closeTime = bar.time;
        this._order.close = bar.close;
        this._order.status = CLOSE;
        this._orders.push(this._order);
        this._order = null;
    }
    this.opened = function() {
        return !!this._order;
    }
    this.output = function() {
        return this._orders;
    }
    this.isInvalid = function(bar, pre) {
        return bar.close >= pre.close * 1.2 || bar.close <= pre.close * 0.8;
    }
}

module.exports = Recorder;
