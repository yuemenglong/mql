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
	void change_state(){
		ORDER_ARRAY tmp;
		list_current_orders(tmp);
		tmp.del();
	}
	void list_current_orders(ORDER_ARRAY& array){
		int total = MTDOrdersTotal();
		for(int i = 0; i < total; i++)
		{
			Order* order = new Order();
			MTDOrderSelect(i, SELECT_BY_POS);
			order._ticket = MTDOrderTicket();
			array.push_back(order);
		}
	}
	void pending(Order* order){
		_pending_time.push_back(order);
	}
};

OrderManager orderManager;

class Order : public ArrayItem
{
public:
	int _ticket;
	int _pending_type;
	datetime _pending_time;
	double _open_price;
	double _stop_loss;
	double _volumn;

	Order(){}
	Order(int pending_type){
		_pending_type = pending_type;
	}
	void set_open_price(double price){
		_open_price = price;
	}
	void set_stop_loss(double stop_loss){
		_stop_loss = stop_loss;
	}
	void set_volumn(double volumn){
		_volumn = volumn;
	}
	void send(){
		_ticket = MTDOrderSend(Symbol(), _pending_type, 
			_volumn, _open_price, 0, _stop_loss);
		_pending_time = Time[0];
		orderManager.pending(this);
		log(str(_ticket));
		log(str(_pending_time));
	}
	int ticket(){
		return _ticket;	
	}
	void select(){
		MTDOrderSelect(SELECT_BY_TICKET, _ticket);
	}
	int order_type(){
		select();
		return MTDOrderType();
	}
	double open_price(){
		select();
		return MTDOrderOpenPrice();
	}
	double volumn(){
		select();
		return MTDOrderLots();
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

