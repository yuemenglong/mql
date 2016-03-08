#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#include <MTDinc.mqh>
#include "kit/kit.mqh";
#include "kit/log.mqh";
#include "kit/label.mqh";
#include "kit/context.mqh";
#include "kit/array.mqh";

ARRAY(int, arr);


class Trace : public ContextBase
{
public:
	virtual int start();
};

int Trace::start(){
	if(arr.size() < 5){
		arr.push_back(arr.size());
	}
	else{
		arr.remove(0, 2);
		for(int i = 0; i < arr.size(); i++){
			log(str(arr[i]));
		}
	}
	return 0;
}

setup(Trace);

