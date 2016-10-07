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
	}
	virtual void deinit(){
		order_clear();
	}
	void open(){
		if(_order != -1){
			log("Order Exists");
			return;
		}
		_order = order_buy();
		log("Order Open");
	}
	void close(){
		if(_order == -1){
			log("Order Not Exists");
			return;
		}
		order_close(_order);
		_order = -1;
		log("Order Close");
	}
	void save(){
		order_save();
	}
	virtual void on_key_down(int key){
		log(str(key));
		if(key == 66){
			open();
		}
		if(key == 67){//check
			close();
		}
		if(key == 83){//save
			save();
		}
	}
};
setup(Stock);
