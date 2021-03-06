#property indicator_chart_window

#include "sys/context.mqh"
#include "view/label.mqh"
#include "view/line.mqh"

extern int indicator_period = 120;
extern color indicator_clr = Lime;

#define MAX 8192

string PREFIX = "TEST_PREFIX_" + indicator_period;

class Test : public Context
{
	HLine _high;
	HLine _low;
	HLine _mid;
public:
	virtual void init(){
		_high.set_id(PREFIX + "HIGH");
		_low.set_id(PREFIX + "LOW");
		_mid.set_id(PREFIX + "MID");
		_high.set_color(indicator_clr);
		_low.set_color(indicator_clr);
		_mid.set_color(indicator_clr);
	}
	virtual void deinit(){
		_high.hide();
		_low.hide();
		_mid.hide();
	}
	virtual void start(){
		double mid = iMA(NULL, 0, indicator_period, 0, MODE_SMA, PRICE_CLOSE, 0);
		int highIdx = iHighest(NULL, 0, MODE_HIGH, indicator_period, 0);
		int lowIdx = iLowest(NULL, 0, MODE_LOW, indicator_period, 0);
		double high = High[highIdx];
		double low = Low[lowIdx];
		_high.set_price(high);
		_high.show();
		_low.set_price(low);
		_low.show();
		_mid.set_price(mid);
		_mid.show();
	}
};

setup(Test);

