//+------------------------------------------------------------------+
//|                                                         test.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#include <MTDinc.mqh>
#include "kit/kit.mqh";
#include "kit/log.mqh";
#include "sys/context.mqh";
#include "view/line.mqh";
#include "view/label.mqh";

extern int SCREEN_NUM = 160;
HLine hline("CURSOR_HLINE");
VLine vline("CURSOR_VLINE");
Label time_label("CURSOR_TIME_LABEL");
Label bar_label("CURSOR_BAR_LABEL");

class Cursor : public Context
{
public:
	virtual void init(){
		enable_mouse_move();
		hline.set_color(clrWhite);
		vline.set_color(clrWhite);
		time_label.set_row(1);
		bar_label.set_row(2);
	}
	virtual void on_mouse_move(int x, int y){
		datetime time = get_time(x);
		double price = get_price(y);
		hline.set_price(price);
		vline.set_time(time);
		hline.show();
		vline.show();
		time_label.set_text(str(time));
		time_label.show();

	}
	virtual void deinit(){
		hline.hide();
		vline.hide();
		time_label.hide();
		bar_label.hide();
	}
	virtual void start(){
		string gap = "    ";
		// int avg = fix(get_shad_avg_height(160, 1.3), 5);
		// int avg = fix(get_k_avg_height(1.3), 5);
		// int mid = fix(get_shad_mid_height(160, 0.7), 5);
		// int mid = fix(get_k_mid_height(0.75), 5);
		// string output = join(str(avg), gap, str(mid));
		// label("TEST_CURSOR_LABEL_AVG", output, 1);
		bar_label.set_text(str(get_k_mid_height(0.7)));
		bar_label.show();
	}
};

setup(Cursor);
