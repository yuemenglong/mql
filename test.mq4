#property indicator_chart_window

#include "sys/context.mqh"

class Test : public Context
{
public:
	virtual void init(){
		
	}
	virtual void start(){
	   	log(str(get_bar_avg_height())); 
	   	log(str(get_bar_mid_height())); 
	   	log(str(get_bar_grid_height())); 
	}
	virtual void on_key_down(int key){
		// Order* order = new Order(OP_BUYSTOP, get_cursor_price(), 0.2);
		// order.set_stop_loss(get_cursor_price() - 0.01);
		// order.send();
	}

};

setup(Test);
