#include <MTDinc.mqh>
#include "../kit/log.mqh"
#include "../std/array.mqh"

class Order;
ARRAY_DEFINE(Order, ORDER_ARRAY);
class OrderManager
{
	ORDER_ARRAY _pending_time;
	ORDER_ARRAY _opened_order;
	ORDER_ARRAY _closed_order;
public:
	void on_new_price(){

	}
	void on_new_bar(){

	}
	void list_current_orders(ORDER_ARRAY& array){
		int total = MTDOrdersTotal();
		for(int i = 0; i < total; i++)
		{
			Order* order = new Order();
			MTDOrderSelect(i, SELECT_BY_POS);
			order._ticket = MTDOrderTicket();
			order._pending_time = MTDOrderOpenTime();
			order._open_price = MTDOrderOpenPrice();
			order._volumn = MTDOrderLots();
			array.push_back(order);
		}
	}
	void panding(Order* order){
		_pending_time.push_back(order);
	}
};

OrderManager orderManager;

class Order : public ArrayItem
{
public:
	int _ticket;
	int _current_type;
	double _open_price;
	double _stop_loss;
	double _volumn;
	datetime _pending_time;

   Order(){}
	Order(int type, double volumn, double price, double stop_loss){
		_current_type = type;
		_volumn = volumn;
		_open_price = price;
		_stop_loss = stop_loss;
		_pending_time = Time[0];
	}
	int ticket(){
		return _ticket;	
	}
	void select(){

	}
	int current_type(){
		return _current_type;
	}
	int order_type(){
		if(_current_type == OP_BUY){
			return OP_BUYSTOP;
		}else if(_current_type == OP_SELL){
			return OP_SELLSTOP;
		}else{
			return _current_type;
		}
	}
	double open_price(){
		return _open_price;
	}
	double volumn(){
		return _volumn;
	}
	void send(){
		int ticket = MTDOrderSend(Symbol(), order_type(), 
			_volumn, _open_price, 0, _stop_loss);
		log(str(ticket));
	}
	virtual bool eq(Order* order){
		if(_ticket == order._ticket){
			return true;
		} else if(_open_price == order._open_price && 
			_pending_time == order._pending_time){
			return true;
		}
		return false;
	}
};

