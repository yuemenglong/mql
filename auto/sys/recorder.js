//openTime, closeTime, open, close, volumn
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
        }
    }
    this.sell = function(bar, volumn) {
        volumn = volumn || 1;
        if (!this._order || !bar.volumn) {
            return;
        }
        this._order.closeTime = bar.time;
        this._order.close = bar.close;
        this._orders.push(this._order);
        this._order = null;
    }
    this.opened = function() {
        return !!this._order;
    }
    this.output = function() {
        return this._orders;
    }
}

module.exports = Recorder;
