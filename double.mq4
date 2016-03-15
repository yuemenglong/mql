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
#include "sys/context.mqh";

extern double stop_loss = 0.003;
extern double ratio = 0.05;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
double mark_price = 0;

class Double : public Context
{
public:
	virtual void start(){
		monitor();
	}
	virtual void deinit(){
		delete_line();
	}
	virtual void on_double_click(int x, int y){
		datetime time = get_time(x);
		double price = get_price(y);
		if(mark_price > 0){
			mark_price = 0;
			delete_line();
		}
		else{        
			mark_price = price;
			create_line();
		}
	}
	virtual void on_key_down(int key){
		double volume = MTDAccountBalance() * ratio / (stop_loss * 100000);
		if(key == 66 && mark_price > 0){
			MTDOrderSend(Symbol(), OP_BUYSTOP, volume, mark_price);
			log("Send Buy");
		}
		if(key == 83 && mark_price > 0){
			MTDOrderSend(Symbol(), OP_SELLSTOP, volume, mark_price);
			log("Send Sell");
		}
	}
	virtual void on_new_bar(){
		log("New Bar");
	}
	virtual void on_new_price(){
		log("New Price");
	}
};
setup(Double);

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
