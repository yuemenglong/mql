#include <MTDinc.mqh>
#include "../kit/log.mqh"
#include "../std/file.mqh"
#include "../view/line.mqh"
#include "context.mqh"

#define MAX_POS 1024
#define PREFIX "ORDER_LINE_"

const int INIT = 0;
const int OPEN = 1;
const int CLOSE = 2;
const int DELETE= 3;


class order_t
{
public:
	datetime openTime;
	datetime closeTime;
	double open;
	double close;
	double volumn;
	int status;//init, open, close, delete

	order_t(){
		status = INIT;
	}
};


class Trade : public Context
{
	order_t _orders[MAX_POS];
	int _order_pos;
public:
	Trade(){
		_order_pos = 0;
	}
	int order_buy(double volumn = 1){
		if(_order_pos >= MAX_POS){
			log("Reach Max Pos, Can't Open New Order");
			return -1;
		}
		int ret = _order_pos++;	
		_orders[ret].openTime = Time[0];
		_orders[ret].open = Close[0];
		_orders[ret].volumn = volumn;
		_orders[ret].status = OPEN;

		string lineName = PREFIX + str(ret);
		HLine line(lineName);
		line.set_color(clrLime);
		line.set_price(Close[0]);
		line.show();

		return ret;
	}
	int order_sell(double volumn = 1){
		return 0;
	}
	int order_close(int ticket){
		if(_orders[ticket].status != OPEN){
			log("Close An Order Which Not Open");
			return -1;
		}
		_orders[ticket].closeTime = Time[0];
		_orders[ticket].close = Close[0];
		_orders[ticket].status = CLOSE;

		string lineName = PREFIX + str(ticket);
		ObjectDelete(lineName);
		Line line(lineName);
		line.set_from(_orders[ticket].openTime, _orders[ticket].open);
		line.set_to(_orders[ticket].closeTime, _orders[ticket].close);
		line.set_color(clrRed);
		line.set_width(2);
		line.show();

		return 0;
	}
	int order_delete_last(){
		if(_order_pos == 0 || _orders[_order_pos-1].status == OPEN){
			log("Can't Delete Order");
			return 0;
		}
		_order_pos--;
		string lineName = PREFIX + _order_pos;
		ObjectDelete(lineName);
		return 0;
	}
	int order_clear(){
		delete_object_prefix(PREFIX);
		return 0;
	}
	int order_save(){
		File* file = new File(Symbol() + ".trade.csv");
		for(int i = 0; i < _order_pos; i++){
			if(_orders[i].status == DELETE){
				continue;
			}
			file.write(_orders[i].openTime);
			file.write(_orders[i].closeTime);
			file.write(_orders[i].open);
			file.write(_orders[i].close);
			file.write(_orders[i].volumn);
			file.write(_orders[i].status);
			file.flush();
		}
		file.close();
		return 0;
	}
};