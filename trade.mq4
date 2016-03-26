#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#include <MTDinc.mqh>
#include "sys/context.mqh";
#include "busi/trade_tracer.mqh";

TradeTracer t1("trade/auto/2010.csv", clrLime);
TradeTracer t2("trade/auto/2010.2.csv", clrRed);

class Trade : public Context
{
public:
	virtual void init(){
		t1.show();
		t2.show();

	}
	virtual void deinit(){
		t1.hide();
		t2.hide();
	}
};

setup(Trade);

