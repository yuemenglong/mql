#property indicator_chart_window

#include <MTDinc.mqh>
#include "kit/log.mqh";
#include "kit/kit.mqh";
#include "sys/trade.mqh";
// #include "view/label.mqh";

class Stock : public Trade
{
	int _order;
public:
	virtual void init(){
		_order = -1;
		order_hide();
		order_show();
	}
	virtual void deinit(){
		order_hide();
	}
	void order_open(){
		if(_order != -1){
			log("Order Exists");
			return;
		}
		_order = order_buy();
		log("Order Open");
	}
	void order_close(){
		if(_order == -1){
			log("Order Not Exists");
			return;
		}
		order_close(_order);
		_order = -1;
		log("Order Close");
	}
	virtual void on_key_down(int key){
		log(str(key));
		if(key == 66){
			order_open();
		}
		if(key == 67){//check
			order_close();
		}
	}
};
setup(Stock);
