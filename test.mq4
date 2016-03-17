#property indicator_chart_window

#include "sys/context.mqh"

void print(INT_ARRAY& arr){
	for(int i = 0; i < arr.size(); i++){
		log(str(arr[i]));
	}
}

class data_t : public ArrayItem
{
public:
	string s;
};
ARRAY_DEFINE(data_t, DATA_ARRAY);

class Listener : public OrderEventListener
{
public:
	virtual void on_order_close(Order* order){
		log("Close");
	}
	virtual void on_order_delete(Order* order){
		log("Delete");
	}
	virtual void on_order_pending(Order* order){
		log("Pending");
	}
	virtual void on_order_open(Order* order){
		log("Open");
	}	
};


class Test : public Context
{
	ORDER_ARRAY arr;
	Listener* listener;
public:
	virtual void init(){
		enable_mouse_move();
		listener = new Listener();
		_order_manager.set_listener(listener);

		int total = MTDOrdersHistoryTotal();
		log(str(total));
	}
	virtual void start(){
	   _order_manager.start();
	}
	virtual void on_key_down(int key){
		Order* order = new Order(OP_BUYSTOP, get_cursor_price(), 0.2);
		order.set_stop_loss(get_cursor_price() - 0.01);
		order.send();
		// int ticket = MTDOrderSend(Symbol(), OP_BUYSTOP, 
			// 0.2, 1.07, 0, 1.05);
		// log(str(ticket));
	}

};

setup(Test);
