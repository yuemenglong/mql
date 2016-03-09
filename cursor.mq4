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
#include "kit/context.mqh";
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
		double array[160];
		double total = 0;
		double high = 0;
		double low = 100;
		for(int i = 0; i < SCREEN_NUM; i++)
		{
			array[i] = MathAbs(Open[i] - Close[i]);
			total += array[i];
			if(High[i] > high){
				high = High[i];
			}
			if(Low[i] < low){
				low = Low[i];
			}
		}
		ArraySort(array);
		int cur = int(MathAbs(Open[0] - Close[0]) * 100000);
		int avg = int(total / SCREEN_NUM * 100000);
		int md = int(array[SCREEN_NUM/3*2] * 100000);
		int scr = int((high - low) / 20 * 0.66 * 100000);
		string gap = "    ";
		string output = join(str(cur), gap, str(md), gap, str(avg), gap, str(scr));
		// label("TEST_CURSOR_LABEL_AVG", output, 1);
		bar_label.set_text(output);
		bar_label.show();
	}
};

setup(Cursor);
