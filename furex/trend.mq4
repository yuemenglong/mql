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
#include "kit/move.mqh";

extern double ratio = 0.05;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
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
	ObjectDelete(0, "TREND_LINE_STOP");
	return 0;
}

//+------------------------------------------------------------------+
void OnChartEvent(const int id,         
  const long& lparam,   
  const double& dparam, 
  const string& sparam  
  )
{
	mouse_move(id, lparam, dparam, sparam);
	if(id != CHARTEVENT_KEYDOWN || lparam != 84){
		return;
	}
	datetime time = mouse_time();
	double price = mouse_price();
	log(str(price));
	if(trend_stop_price == 0){
		trend_stop_price = price;
		ObjectCreate(0, "TREND_LINE_STOP", OBJ_HLINE, 0, Time[0], trend_stop_price);
		ObjectSetInteger(0, "TREND_LINE_STOP", OBJPROP_COLOR, clrRed);
	}
	else{
		log("Send Trend Order");
		double stop_loss = MathAbs(price - trend_stop_price);
		double volumn = MTDAccountBalance() * ratio / (stop_loss * 100000);
		int op = price > trend_stop_price ? OP_BUYSTOP : OP_SELLSTOP;
		MTDOrderSend(Symbol(), op, volumn, price, 0, trend_stop_price);
		trend_stop_price = 0;
		ObjectDelete(0, "TREND_LINE_STOP");
	}
	return;
}
