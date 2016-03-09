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

ARRAY_DEFINE(trade_t, TRADE_ARRAY);
TRADE_ARRAY trade_array;

class Trade : public Context
{
public:
	virtual void init(){
		file.read_line();
		file.read_line();
		while(!file.reach_end()){
			trade_array.push_back();
			array_back(trade_array).open_time = file.read_time();
			array_back(trade_array).type = file.read_string();
			array_back(trade_array).volumn = file.read_double();
			array_back(trade_array).symbol = file.read_string();
			array_back(trade_array).open_price = file.read_double();
			array_back(trade_array).sl = file.read_string();
			array_back(trade_array).tp = file.read_string();
			array_back(trade_array).close_time = file.read_time();
			array_back(trade_array).close_price = file.read_double();
			array_back(trade_array).commission = file.read_string();
			array_back(trade_array).swap = file.read_string();
			array_back(trade_array).profit = file.read_double();
			array_back(trade_array).comment = file.read_string();
		}
		for(int i = 0; i < trade_array.size(); i++){
			datetime open_time = array_get(trade_array, i).open_time;
			log(str(open_time));
		}
	}
	virtual void start(){
	}
	virtual void deinit(){
		file.close();
	}
};

setup(Trade);

