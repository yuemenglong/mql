#property indicator_chart_window

#include "sys/context.mqh"
#include "view/label.mqh"
#include "view/line.mqh"

extern int indicator_period = 120;
extern int indicator_width = 1;
extern color indicator_clr = FireBrick;

string PREFIX = "TIME_SPAN_PREFIX_" + indicator_period;

class TimeSpan : public Context
{
	VLine _line;
public:
	virtual void init(){
		_line.set_id(PREFIX);
		_line.set_color(indicator_clr);
		_line.set_width(indicator_width);
	}
	virtual void deinit(){
		_line.hide();
	}
	virtual void start(){
		_line.set_time(Time[indicator_period]);
		_line.show();
	}
};

setup(TimeSpan);

