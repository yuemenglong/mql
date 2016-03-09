#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#include <MTDinc.mqh>
#include "kit/kit.mqh";
#include "kit/log.mqh";
#include "kit/context.mqh";
#include "std/file.mqh";
#include "std/array.mqh";

ARRAY_DEFINE(int, INT_ARRAY);

class Trace : public Context
{
public:
	virtual void init(){
		INT_ARRAY arr;
		File file("trade/sdpzqs/2011.csv");
		for(int i = 0; i < 50; i++){
			string ret = file.read_string();
			if(StringLen(ret) == 0){
				break;
			}
			string spl[20];
			StringSplit(ret, ',', spl);
			for(int j = 0; j < ArraySize(spl); j++){
				log(spl[j]);
			}
		}
		file.close();
	}
	virtual void start(){
		ObjectCreate("ARROR",OBJ_ARROW,0,Time[0],Close[0]);
	}
	virtual void deinit(){
		ObjectDelete("ARROR");
	}
};

setup(Trace);

