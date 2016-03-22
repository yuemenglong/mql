#include <MTDinc.mqh>
#include "../std/array.mqh"
#include "../kit/log.mqh"

class Order : public ArrayItem
{
public:
	int _ticket;
	int _op;
	datetime _pending_time;
	double _pending_price;
	double _stop_loss;
	double _volumn;

	Order(int ticket){
		_ticket = ticket;
		_op = type();
		_pending_price = open_price();
		_volumn = volumn();
	}
	Order(int type, double price, double volumn){
		_op = type;
		_pending_price = price;
		_volumn = volumn;
	}
	void set_op(int type){
		_op = type;
	}
	int get_op(){
		return _op;
	}
	void set_pending_price(double price){
		_pending_price = price;
	}
	void set_stop_loss(double price){
		_stop_loss = price;
	}
	void set_volumn(double volumn){
		_volumn = volumn;
	}
	bool send(){
		_ticket = MTDOrderSend(Symbol(), _op, 
			_volumn, _pending_price, 0, _stop_loss);
		_pending_time = Time[0];
		return true;
	}
	bool modify(){
		MTDOrderModify(_ticket, _pending_price, _stop_loss);
		return true;
	}
	bool close(){
		MTDOrderClose(_ticket, _volumn, Close[0]);
		return true;
	}
	bool del(){
		bool ret = MTDOrderDelete(_ticket);
		return true;
	}
	int ticket(){
		return _ticket;	
	}
	bool select(){
		// bool ret = MTDOrderSelect(SELECT_BY_TICKET, _ticket);
		int total = MTDOrdersTotal();
		for(int i = 0; i < total; i++){
			MTDOrderSelect(i, SELECT_BY_POS);
			int ticket = MTDOrderTicket();
			if(ticket == _ticket){
				return true;
			}
		}
		return false;
	}
	bool select_history(){
		int total = MTDOrdersHistoryTotal();
		for(int i=0;i < total; i++){
			MTDOrderSelect(i, SELECT_BY_POS, MODE_HISTORY);
			if(MTDOrderTicket() == _ticket){
				return true;
			}
		}
		return false;
	}
	int type(){
		if(!select() && !select_history()){
			return -1;
		}
		return MTDOrderType();
	}
	double open_price(){
		if(!select() && !select_history()){
			return -1;
		}
		return MTDOrderOpenPrice();
	}
	double stop_loss(){
		if(!select() && !select_history()){
			return -1;
		}
		return MTDOrderStopLoss();	
	}
	datetime open_time(){
		if(!select() && !select_history()){
			return -1;
		}
		return MTDOrderOpenTime();
	}
	double volumn(){
		if(!select() && !select_history()){
			return -1;
		}
		return MTDOrderLots();
	}
	
	virtual bool eq(Order* order){
		if(_ticket == order._ticket){
			return true;
		}
		return false;
	}
};

ARRAY_DEFINE(Order, ORDER_ARRAY);


class OrderStatic
{
public:
	static void get_orders(ORDER_ARRAY& array){
		int total = MTDOrdersTotal();
		for(int i = 0; i < total; i++)
		{
			MTDOrderSelect(i, SELECT_BY_POS);
			Order* order = new Order(MTDOrderTicket());
			array.push_back(order);
		}
	}

	static void get_history_orders(ORDER_ARRAY& array){
		int total = MTDOrdersHistoryTotal();
		for(int i = 0; i < total; i++)
		{
			MTDOrderSelect(i, SELECT_BY_POS, MODE_HISTORY);
			Order* order = new Order(MTDOrderTicket());
			array.push_back(order);
		}
	}
};