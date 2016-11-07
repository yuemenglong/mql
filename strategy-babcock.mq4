#property indicator_chart_window

#include "sys/context.mqh"
#include "sys/auto.mqh"
#include "view/label.mqh"
#include "view/line.mqh"

extern int short_period = 20;
extern int long_period = 120;

string PREFIX = "BABCOOK_PREFIX_";

double RATIO = 0.1;

class Babcook : public Auto
{
	double _buy;
	double _sell;
	Label _label;
	HLine _buy_line;
	HLine _sell_line;
public:
	virtual void init(){
		reset();
		_label.set_id(PREFIX + "LABEL");
		_label.set_corner(1, 0);
		_label.set_text("hello");

		_buy_line.set_id(PREFIX + "BUY");
		_buy_line.set_color(clrLime);
		_buy_line.set_style(STYLE_DASHDOT);

		_sell_line.set_id(PREFIX + "SELL");
		_sell_line.set_color(clrRed);
		_sell_line.set_style(STYLE_DASHDOT);
		show_view();
	}
	virtual void deinit(){
		delete_object_prefix(PREFIX);
	}
	void show_view(){
		double volumn = (Close[0] - _sell) / Close[0];
		double buy = 0;
		if(_buy < 10000){
			buy = _buy;
		}
		_label.set_text(str(buy, 2) + " / " + str(_sell, 2)+" / " + str(volumn, 2));
		_label.show();
		if(_buy < 10000){
			_buy_line.set_price(_buy);
			_buy_line.show();
		} else {
			_buy_line.hide();
		}
		if(_sell > 0){
			_sell_line.set_price(_sell);
			_sell_line.show();
		} else {
			_sell_line.hide();
		}
	}
	void reset(){
		_buy = 10000;
		int longLowIdx = iLowest(NULL, 0, MODE_LOW, long_period, 0);
		if(longLowIdx < 0){
			_sell = 0;
		} else {
			_sell = Low[longLowIdx];
		}
	}
	virtual void start(){
		// int longHighIdx = iHighest(NULL, 0, MODE_HIGH, long_period, 0);
		int longLowIdx = iLowest(NULL, 0, MODE_LOW, long_period, 0);
		int shortHighIdx = iHighest(NULL, 0, MODE_HIGH, short_period, longLowIdx);
		if(shortHighIdx >= 0){
			_buy = High[shortHighIdx];
		}
		if(longLowIdx > 0){
			_sell = Low[longLowIdx];
		}
		show_view();
	}
	virtual void on_key_down(int key){
		Auto::on_key_down(key);
		if(key == 85){ //u
			reset();
			show_view();
		}
	}
};

setup(Babcook);

