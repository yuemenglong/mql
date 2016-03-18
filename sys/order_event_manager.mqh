#include <MTDinc.mqh>
#include "../kit/log.mqh"
#include "../std/array.mqh"
#include "order.mqh"

ARRAY_DEFINE(Order, ORDER_ARRAY);

class OrderEventListener
{
public:
	virtual void on_order_pending(Order* order){}
	virtual void on_order_open(Order* order){}
	virtual void on_order_close(Order* order){}
	virtual void on_order_delete(Order* order){}
};

class OrderEventManager
{
	ORDER_ARRAY _pending_list;
	ORDER_ARRAY _opened_list;
	OrderEventListener* _listener;
public:
	void start(){
		check_state();
	}
	void set_listener(OrderEventListener* listener){
		_listener = listener;
	}
	void notify_order_open(Order* order){
		if(_listener){
			_listener.on_order_open(order);
		}
	}
	void notify_order_close(Order* order){
		if(_listener){
			_listener.on_order_close(order);
		}
	}
	void notify_order_pending(Order* order){
		if(_listener){
			_listener.on_order_pending(order);
		}
	}
	void notify_order_delete(Order* order){
		if(_listener){
			_listener.on_order_delete(order);
		}
	}
	void check_state(){
		ORDER_ARRAY current_list;
		list_current_orders(current_list);
		int i = 0;
		Order* order = NULL;
		for(i = 0; i < current_list.size(); i++){
			order = current_list[i];
			if(_pending_list.find(order) < 0 && _opened_list.find(order) < 0){
				_pending_list.push_back(order);
				current_list.remove(i);
				i--;
				notify_order_pending(order);
			}
		}
		for(i = 0; i < _pending_list.size(); i++){
			order = _pending_list[i];
			if(!order.select()){
				_pending_list.remove(i);
				i--;
				notify_order_delete(order);
				delete order;
				continue;
			}
			int type = order.order_type();
			if(type == 0 || type == 1){
				_opened_list.push_back(order);
				_pending_list.remove(i);
				i--;
				notify_order_open(order);
				continue;
			}
		}
		for(i = 0; i < _opened_list.size(); i++){
			order = _opened_list[i];
			if(order.select_history()){
				_opened_list.remove(i);
				i--;
				notify_order_close(order);
				delete order;
				continue;
			}
			if(!order.select()){
				_opened_list.remove(i);
				i--;
				notify_order_delete(order);
				delete order;
				continue;
			}
		}
		current_list.del();
	}
	void list_current_orders(ORDER_ARRAY& array){
		int total = MTDOrdersTotal();
		for(int i = 0; i < total; i++)
		{
			MTDOrderSelect(i, SELECT_BY_POS);
			Order* order = new Order(MTDOrderTicket());
			array.push_back(order);
		}
	}
};

OrderEventManager _order_event_manager;

