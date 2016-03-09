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

File file("trade/sdpzqs/2011.csv");

struct trade_t
{
	datetime open_time;
	datetime close_time;
	double open_price;
	double close_price;	
	double volumn;
	double account;
	double profit;
	string type;
	string symbol, sl, tp, commission, swap, comment;
};

struct trade_list_t
{
	trade_t list[128];
	int len;
};

struct line_list_t
{
	int len;
};

class Trade : public Context
{
public:
	virtual void init(){
		trade_list_t trades;	
		file.read_line();
		file.read_line();
		while(!file.reach_end()){
			trades.list[trades.len].open_time = file.read_time();
			trades.list[trades.len].type = file.read_string();
			trades.list[trades.len].volumn = file.read_double();
			trades.list[trades.len].symbol = file.read_string();
			trades.list[trades.len].open_price = file.read_double();
			trades.list[trades.len].sl = file.read_string();
			trades.list[trades.len].tp = file.read_string();
			trades.list[trades.len].close_time = file.read_time();
			trades.list[trades.len].close_price = file.read_double();
			trades.list[trades.len].commission = file.read_string();
			trades.list[trades.len].swap = file.read_string();
			trades.list[trades.len].profit = file.read_double();
			trades.list[trades.len].comment = file.read_string();
			trades.len++;
		}
	}
	virtual void start(){
	}
	virtual void deinit(){
		file.close();
	}
};

setup(Trade);

