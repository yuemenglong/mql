#property indicator_chart_window

#include "sys/context.mqh"
#include "busi/order_manager.mqh"

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

class Test : public Context
{
	ORDER_ARRAY arr;
public:
	virtual void start(){
	}
	virtual void on_key_down(int key){
		/*Order* n = new Order(OP_BUYSTOP, 0.2, 1.07, 1.05);
		n.send();*/
		int ticket = MTDOrderSend(Symbol(), OP_BUYSTOP, 
			0.2, 1.07, 0, 1.05);
		log(str(ticket));
	}

};

setup(Test);
