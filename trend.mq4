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
#include "kit/kit.mqh";

extern double ratio = 0.05;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
double trend_mark_price = 0;
double trend_stop_price = 0;

int init()
{
	log("init");
	// wave_init();
	return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
	//log("start");
	return 0;
}

int deinit()
{
	log("deinit");
	delete_line();
	return 0;
}

//+------------------------------------------------------------------+
void OnChartEvent(const int id,         
  const long& lparam,   
  const double& dparam, 
  const string& sparam  
  )
{
	if(IsDoubleClick(id, lparam,dparam,sparam)){
		DoubleClick(id, lparam, dparam, sparam);
	}
	if(id != CHARTEVENT_KEYDOWN){
		return;
	}
	if(lparam != 84){
		return;
	}	
	if(trend_mark_price == 0 || trend_mark_price == trend_stop_price){
		trend_stop_price = 0;
		ObjectDelete(0, "TREND_LINE_STOP");
	}
	else if(trend_stop_price == 0){
		trend_stop_price = trend_mark_price;
		ObjectCreate(0, "TREND_LINE_STOP", OBJ_HLINE, 0, Time[0], trend_stop_price);
		ObjectSetInteger(0, "TREND_LINE_STOP", OBJPROP_COLOR, clrRed);
	}
	else {
		log("Send Order");
		double stop_loss = MathAbs(trend_mark_price - trend_stop_price);
		double stop_win_price = 2 * trend_mark_price - trend_stop_price;
		double volumn = MTDAccountBalance() * ratio / (stop_loss * 100000);
		int op = trend_mark_price > trend_stop_price ? OP_BUYSTOP : OP_SELLSTOP;
		MTDOrderSend(Symbol(), op, volumn, trend_mark_price, 0, trend_stop_price, stop_win_price);
		trend_stop_price = 0;
		ObjectDelete(0, "TREND_LINE_STOP");
	}
	trend_mark_price = 0;
	delete_line();
}

void delete_line(){
	ObjectDelete(0, "TREND_LINE_CUR");
}

void create_line(){
	ObjectCreate(0, "TREND_LINE_CUR", OBJ_HLINE, 0, Time[0], trend_mark_price);
	ObjectSetInteger(0, "TREND_LINE_CUR", OBJPROP_COLOR, clrLimeGreen);
}

void DoubleClick(const int id,          
  const long& lparam,    
  const double& dparam, 
  const string& sparam   
  )
{
	int x = (int)lparam;
	int y = (int)dparam;
	datetime time;
	double price;
	int sub_window;
	ChartXYToTimePrice(0, x, y, sub_window, time, price);
	price = (int)(price * 100000) / 100000.0;
	if(trend_mark_price > 0)
	{
		trend_mark_price = 0;
		delete_line();
	}
	else
	{        
		trend_mark_price = price;
		create_line();
	}
}