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

extern double stop_loss = 0.005;
extern double ratio = 0.05;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
double mark_price = 0;
double stop_price = 0;

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
	monitor();
	return 0;
}

int deinit()
{
	log("deinit");
	delete_line();
	return 0;
}

void monitor()
{
	int total = MTDOrdersTotal();
	for(int i = 0; i < total; i++)
	{
		MTDOrderSelect(i, SELECT_BY_POS);
		// if(MTDOrderOpenTime() != MTDTimeCurrent())
		// {
		// 	continue;
		// }		
		int op = MTDOrderType();
		if(op != OP_BUY && op != OP_SELL)
		{
			continue;
		}
		double sl = MTDOrderStopLoss();
		if(sl != 0){
			continue;
		}
		double price = MTDOrderOpenPrice();
		double volume = MTDOrderLots();
		int ticket = MTDOrderTicket();
		if(op == OP_BUY)
		{
			MTDOrderModify(ticket, price, price - stop_loss);
			log("Buy Stop Loss");
		}
		else if(op == OP_SELL)
		{
			MTDOrderModify(ticket, price, price + stop_loss);
			log("Sell Stop Loss");
		}
	}
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
	if(id == CHARTEVENT_KEYDOWN){
		double volume = MTDAccountBalance() * ratio / (stop_loss * 100000);
		if(lparam == 66 && mark_price > 0){
			MTDOrderSend(Symbol(), OP_BUYSTOP, volume, mark_price);
			log("Send Buy");
		}
		if(lparam == 83 && mark_price > 0){
			MTDOrderSend(Symbol(), OP_SELLSTOP, volume, mark_price);
			log("Send Sell");
		}
		if(lparam == 84){
			if(mark_price == 0){
				stop_price = 0;
				ObjectDelete(0, "TEST_LINE_STOP");
				return;
			}
			if(stop_price == 0){
				stop_price = mark_price;
				ObjectCreate(0, "TEST_LINE_STOP", OBJ_HLINE, 0, Time[0], stop_price);
				ObjectSetInteger(0, "TEST_LINE_STOP", OBJPROP_COLOR, clrRed);
				return;
			}
			log("Send Order");
			double s = MathAbs(mark_price - stop_price);
			double v = MTDAccountBalance() * ratio / (s * 100000);
			int op = mark_price > stop_price ? OP_BUYSTOP : OP_SELLSTOP;
			MTDOrderSend(Symbol(), op, v, mark_price, 0, stop_price);
			stop_price = 0;
			ObjectDelete(0, "TEST_LINE_STOP");
		}
	} 
}

void delete_line(){
	ObjectDelete(0, "TEST_LINE_CUR");
	ObjectDelete(0, "TEST_LINE_UP_LOSS");
	ObjectDelete(0, "TEST_LINE_DOWN_LOSS");
}

void create_line(){
	ObjectCreate(0, "TEST_LINE_CUR", OBJ_HLINE, 0, Time[0], mark_price);
	ObjectSetInteger(0, "TEST_LINE_CUR", OBJPROP_COLOR, clrLimeGreen);
	ObjectCreate(0, "TEST_LINE_UP_LOSS", OBJ_HLINE, 0, Time[0], mark_price + stop_loss);
	ObjectSetInteger(0, "TEST_LINE_UP_LOSS", OBJPROP_COLOR, clrRed);
	ObjectCreate(0, "TEST_LINE_DOWN_LOSS", OBJ_HLINE, 0, Time[0], mark_price - stop_loss);
	ObjectSetInteger(0, "TEST_LINE_DOWN_LOSS", OBJPROP_COLOR, clrRed);
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
	if(mark_price > 0)
	{
		mark_price = 0;
		delete_line();
	}
	else
	{        
		mark_price = price;
		create_line();
	}
}