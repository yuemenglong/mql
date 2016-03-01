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
#include "kit/log.mqh";

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
	ObjectDelete(0, "TEST_CURSOR_LABEL_X");
	ObjectDelete(0, "TEST_CURSOR_LABEL_Y");
	ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 0, false);
	return 0;
}

int start()
{
	return 0;
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

	MTDlabel("TEST_CURSOR_LABEL_X", str(time), Lime, 20, 10, 10);
	MTDlabel("TEST_CURSOR_LABEL_Y", str(price), Lime, 20, 10, 40);
}