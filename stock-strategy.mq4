#property indicator_chart_window

#include "sys/auto.mqh"

int SHORT = 6;
int LONG = 18;

class Strategy : public Auto
{
public:
	virtual void exec(){
		if(!auto_opened() && ema(SHORT) > ema(LONG)){
			auto_buy();
		}else if(auto_opened() && ema(SHORT) < ema(LONG)){
			auto_close();
		}
	}
};
setup(Strategy);
