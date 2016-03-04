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

extern int SCREEN_NUM = 160;

int init()
{
	log("Init Cursor");
	ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 0, true);
	return 0;
}

int deinit()
{
	log("Deinit Cursor");
	ObjectDelete(0, "TEST_CURSOR_X");
	ObjectDelete(0, "TEST_CURSOR_Y");
	ObjectDelete(0, "TEST_CURSOT_LABEL_TIME");
	ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 0, false);
	return 0;
}

int start()
{
	calc();
	return 0;
}

void calc()
{
	double array[160];
	if(160 < SCREEN_NUM)
	{
		ArrayResize(array, SCREEN_NUM);
	}
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
	label("TEST_CURSOR_LABEL_AVG", output, 1);
}

//+------------------------------------------------------------------+
void OnChartEvent(const int id,         
  const long& lparam,   
  const double& dparam, 
  const string& sparam  
  )
{
	if(id == CHARTEVENT_MOUSE_MOVE){
		int x = (int)lparam;
		int y = (int)dparam;
		datetime time;
		double price;
		int sub_window;
		ChartXYToTimePrice(0, x, y, sub_window, time, price);
		reline(time, price);
	}
}

void reline(datetime time, double price)
{
	ObjectDelete(0, "TEST_CURSOR_X");
	ObjectDelete(0, "TEST_CURSOR_Y");

	ObjectCreate(0, "TEST_CURSOR_X", OBJ_HLINE, 0, time, price);
	ObjectSetInteger(0, "TEST_CURSOR_X", OBJPROP_COLOR, clrWhite);
	ObjectCreate(0, "TEST_CURSOR_Y", OBJ_VLINE, 0, time, price);
	ObjectSetInteger(0, "TEST_CURSOR_Y", OBJPROP_COLOR, clrWhite);

	// MTDlabel("TEST_CURSOT_LABEL_TIME_X", str(time), Lime, 20, 10, 10);
	label("TEST_CURSOT_LABEL_TIME", join(str(time), "    ", str(price)), 0);
	// MTDlabel("TEST_CURSOT_LABEL_TIME_Y", str(price), Lime, 20, 10, 40);
}