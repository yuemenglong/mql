#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#include <MTDinc.mqh>
#include "kit/log.mqh";
#include "kit/context.mqh";
#include "std/file.mqh";
#include "std/array.mqh";
#include "busi/trade_tracer.mqh";

TradeTracer t1("trade/sdpzqs/2011.csv", clrLime, 0);

class Trade : public Context
{
public:
	virtual void init(){
		t1.show_line();
	}
	virtual void start(){
	   t1.show_detail();
	}
	virtual void deinit(){
		t1.hide();
	}
};

setup(Trade);

