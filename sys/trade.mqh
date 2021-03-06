#include <MTDinc.mqh>
#include "../kit/log.mqh"
#include "../std/file.mqh"
#include "../view/line.mqh"
#include "context.mqh"

#define MAX_POS 4096
string ORDER_LINE_PREFIX = "ORDER_LINE_";

const int INIT = 0;
const int OPEN = 1;
const int CLOSE = 2;
const int DELETE= 3;

class order_t
{
public:
	datetime open_time;
	datetime close_time;
	double open;
	double close;
	double volumn;
	int status;//init, open, close, delete
	int ticket;

	order_t(){
		status = INIT;
	}
};

class OrderView
{
	int _clr;
	string get_prefix(){
		return ORDER_LINE_PREFIX + str(_clr) + "_";
	}
public:
	OrderView(int clr){
		_clr = clr;
	}
	~OrderView(){
		hide();
	}
	int show(order_t& orders[], int size){
		for(int i = 0; i < size; i++){
			order_t* order = &orders[i];
		   string lineName = get_prefix() + str(order.ticket);
			if(order.status == OPEN){
				HLine line(lineName);
				line.set_color(clrLime);
				line.set_price(order.open);
				line.show();
			}else if(order.status == CLOSE){
				Line line(lineName);
				line.set_from(order.open_time, order.open);
				line.set_to(order.close_time, order.close);
				line.set_color(_clr);
				line.set_width(2);
				line.show();
			}
		}
		return 0;
	}
	int hide(){
		Static::delete_object_prefix(get_prefix());
		return 0;
	}
};


class Trade : public Context
{
	order_t _orders[MAX_POS];
	int _order_pos;
	OrderView view;
	OrderView view2;
public:
	Trade() : view(clrRed), view2(clrBlue) {
		_order_pos = 0;
	}
	int order_buy(double volumn = 1){
		if(_order_pos >= MAX_POS){
			log("Reach Max Pos, Can't Open New Order");
			return -1;
		}
		int ticket = _order_pos++;	
		_orders[ticket].ticket = ticket;
		_orders[ticket].open_time = Time[0];
		_orders[ticket].open = Close[0];
		_orders[ticket].volumn = volumn;
		_orders[ticket].status = OPEN;
		// order_show(_orders[ticket]);
		view.hide();
		view.show(_orders, _order_pos);

		return ticket;
	}
	int order_sell(double volumn = 1){
		return 0;
	}
	int order_close(int ticket, double close = 0){
		if(_orders[ticket].status != OPEN){
			log("Close An Order Which Not Open");
			return -1;
		}
		close = close == 0 ? Close[0] : close;
		_orders[ticket].close_time = Time[0];
		_orders[ticket].close = close;
		_orders[ticket].status = CLOSE;
		// order_show(_orders[ticket]);
		view.hide();
		view.show(_orders, _order_pos);

		return 0;
	}
	int order_delete_last(){
		if(_order_pos == 0){
			log("Can't Delete Order");
			return 0;
		}
		_order_pos--;
		view.hide();
		view.show(_orders, _order_pos);
		return 0;
	}
	int order_clear(){
		_order_pos = 0;
		view.hide();
		view2.hide();
		// delete_object_prefix(PREFIX);
		return 0;
	}
	int order_save(){
		string fileName = Symbol() + ".trade.csv";
		File::del(fileName);
		File* file = new File(fileName);
		for(int i = 0; i < _order_pos; i++){
			if(_orders[i].status == DELETE){
				continue;
			}
			file.write(_orders[i].open_time);
			file.write(_orders[i].close_time);
			file.write(_orders[i].open);
			file.write(_orders[i].close);
			file.write(_orders[i].volumn);
			file.write(_orders[i].status);
			file.flush();
		}
		file.close();
		return 0;
	}
private:
	int order_load(string fileName, order_t& orders[], int& pos){
		File* file = new File(fileName);
		if(!file.valid()){
			return -1;
		}
		pos = 0;
		while(!file.reach_end()){
			orders[pos].ticket = pos;
			orders[pos].open_time = file.read_time();
			orders[pos].close_time = file.read_time();
			orders[pos].open = file.read_double();
			orders[pos].close = file.read_double();
			orders[pos].volumn = file.read_integer();
			orders[pos].status = file.read_integer();
			// order_show(orders[pos], clr);
			pos++;
		}
		file.close();

		return 0;
	}
public:
	int order_load(){
		string fileName = Symbol() + ".trade.csv";
		order_load(fileName, _orders, _order_pos);
		view.hide();
		view.show(_orders, _order_pos);
		return 0;
	}
	int order_load_2(){
		string fileName = Symbol() + ".trade.2.csv";
		order_t orders[MAX_POS];
		int pos;
		order_load(fileName, orders, pos);
		view2.hide();
		view2.show(orders, pos);
		return 0;
	}
};
