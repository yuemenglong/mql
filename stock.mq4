#property indicator_chart_window

#include <MTDinc.mqh>
#include "kit/log.mqh";
#include "kit/kit.mqh";
#include "sys/context.mqh";
// #include "view/label.mqh";

class Stock : public Context
{
	Order* _order;
public:
	virtual void init(){
		_order = NULL;
	}
	virtual void deinit(){

	}
	void order_open(){
		if(_order){
			log("Order Exists");
			return;
		}
		double price = Close[0];
		_order = new Order(OP_BUY, Close[0], 1);
		_order.send();
		log("Order Open");
	}
	void order_close(){
		if(!_order){
			log("Order Not Exists");
			return;
		}
		_order.close();
		_order = NULL;
		log("Send Close");
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
