#property indicator_chart_window

#include "sys/context.mqh"

class Test : public Context
{
	Order* order;
public:
	virtual void init(){
		order = new Order(OP_SELL, Close[0], 0.2);	
		order.send();
	   
	}
	virtual void start(){
		order.select();
	}
	virtual void on_key_down(int key){
		// Order* order = new Order(OP_BUYSTOP, get_cursor_price(), 0.2);
		// order.set_stop_loss(get_cursor_price() - 0.01);
		// order.send();
	}
	virtual void deinit(){
		order.del();
	}

};

setup(Test);
