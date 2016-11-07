#property indicator_chart_window

#include "sys/context.mqh"
#include "view/label.mqh"
#include "view/line.mqh"

extern int indicator_period = 120;
extern int indicator_width = 1;
extern double indicator_ratio_1 = 0;
extern double indicator_ratio_2 = 0;
extern color indicator_clr_main = clrFireBrick;
extern color indicator_clr_ratio = clrWhite;

#define MAX 8192

string PREFIX = "HIGH_LOW_PREFIX_" + indicator_period;

class HighLow : public Context
{
	HLine _high;
	HLine _low;
	HLine _mid_1;
	HLine _mid_2;
	VLine _span_line;
public:
	virtual void init(){
		_high.set_id(PREFIX + "HIGH");
		_low.set_id(PREFIX + "LOW");
		_span_line.set_id(PREFIX + "SPAN");
		_mid_1.set_id(PREFIX + "MID_1");
		_mid_2.set_id(PREFIX + "MID_2");

		_high.set_color(indicator_clr_main);
		_low.set_color(indicator_clr_main);
		_span_line.set_color(indicator_clr_main);
		_mid_1.set_color(indicator_clr_ratio);
		_mid_2.set_color(indicator_clr_ratio);

		_high.set_width(indicator_width);
		_low.set_width(indicator_width);
		_span_line.set_width(indicator_width);
		_mid_1.set_width(indicator_width);
		_mid_2.set_width(indicator_width);
	}
	virtual void deinit(){
		_high.hide();
		_low.hide();
		_span_line.hide();
		_mid_1.hide();
		_mid_2.hide();
	}
	virtual void start(){
		// double mid = iMA(NULL, 0, indicator_period, 0, MODE_SMA, PRICE_CLOSE, 0);
		int highIdx = iHighest(NULL, 0, MODE_HIGH, indicator_period, 0);
		int lowIdx = iLowest(NULL, 0, MODE_LOW, indicator_period, 0);
		double high = High[highIdx];
		double low = Low[lowIdx];
		_high.set_price(high);
		_high.show();
		_low.set_price(low);
		_low.show();
		_span_line.set_time(Time[indicator_period]);
		_span_line.show();
		if(0 < indicator_ratio_1 && indicator_ratio_1 < 1){
			double mid_1 = low + (high - low) * indicator_ratio_1;
			_mid_1.set_price(mid_1);
			_mid_1.show();
		}
		if(0 < indicator_ratio_2 && indicator_ratio_1 < 2){
			double mid_2 = low + (high - low) * indicator_ratio_2;
			_mid_2.set_price(mid_2);
			_mid_2.show();
		}
	}
};

setup(HighLow);

