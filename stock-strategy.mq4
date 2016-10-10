#property indicator_chart_window

#include "sys/auto.mqh"

class Strategy : public Auto
{
public:
	virtual void exec(){
		if(!auto_opened() && ema(6) > ema(18)){
			auto_buy();
		}else if(auto_opened() && ema(6) < ema(18)){
			auto_close();
		}
	}
};
setup(Strategy);
