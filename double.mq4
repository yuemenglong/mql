//+------------------------------------------------------------------+
//|                                                         test.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#include <MTDinc.mqh>
#include "kit/log.mqh";
#include "kit/kit.mqh";
#include "sys/context.mqh";

extern double stop_loss = 0.003;
extern double ratio = 0.05;

double meta_stop_loss = stop_loss / 3;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

// 1. 触发开仓后没有突破，平仓后继续开
// 2. 影线止损后继续开
// 3. 实体止损后再开一次
class ReopenMonitor : public ArrayItem
{
	Order* _order;
	int _type;
	int _stop_times;
public:
	ReopenMonitor(Order* order){
		_order = order;
		_type = order.type();
		_stop_times = 0;
	}
	void on_new_bar(){
		log(str(_type));
		// 1. 触发开仓后没有突破，平仓后继续开
		if(_type < 2){
			return;
		}
		_type = _order.type();
		if(_type >= 2){
			return;
		}
		if(_type == OP_BUY && Close[0] < _order.open_price()){
			_order.close();
			_order.send();
		} else if(_type == OP_SELL && Close[0] > _order.open_price()){
			_order.close();
			_order.send();
		}
	}
	void on_new_price(){

	}
	void del(){
		delete _order;
	}
};


ARRAY_DEFINE(ReopenMonitor, REOPEN_MONITOR_ARRAY);

class Double : public Context
{
	double _mark_price;
	INT_ARRAY _break_array;
	Order* _last_order;
public:
	virtual void deinit(){
		delete_line();
	}
	virtual void on_double_click(int x, int y){
		datetime time = get_time(x);
		double price = get_price(y);
		if(_mark_price > 0){
			_mark_price = 0;
			delete_line();
		}
		else{        
			_mark_price = price;
			create_line(price);
		}
	}
	virtual void on_key_down(int key){
		log(str(key));
		double volumn = MTDAccountBalance() * ratio / (stop_loss * 100000);
		if(key == 66){
			double price = _mark_price;
			if(price == 0){
				price = get_upper_price();
				if(Close[0] > price){
					log("Invalid Adjust");
					return;
				}
			}
			Order* order = new Order(OP_BUYSTOP, price, volumn);
			order.set_stop_loss(price - stop_loss);
			order.send();
			_last_order = order;
			log("Send Buy");
		}
		if(key == 83){
			double price = _mark_price;
			if(price == 0){
				price = get_lower_price();
				if(Close[0] < price){
					log("Invalid Adjust");
					return;
				}
			}
			Order* order = new Order(OP_SELLSTOP, price, volumn);
			order.set_stop_loss(price + stop_loss);
			order.send();
			_last_order = order;
			log("Send Sell");
		}
		if(key == 67){
			Order* order = _last_order;
			int ticket = order.ticket();
			if(_break_array.find(ticket) >= 0){
				return;
			}
			if(order.type() >= 2){
				return;
			}
			if(order.type() == OP_BUY && order.open_price() > Close[0]){
				order.close();
				log("Close Buy");
			} else if(order.type() == OP_SELL && order.open_price() < Close[0]){
				order.close();
				log("Close Sell");
			} else{
				_break_array.push_back(ticket);
				log("Break Succ");
			}
		}
		if(key == 82){
			if(_last_order){
				_last_order.set_volumn(volumn);
				_last_order.send();
				log("Resend");
			}
		}
		if(key == 68){
			if(_last_order){
				_last_order.set_stop_loss(0);
				_last_order.modify();
			}	
		}
	}
};
setup(Double);

double get_lower_price(int n = 5){
	DOUBLE_ARRAY arr;
	for(int i = 1; i < n; i++){
		arr.push_back(Open[i]);
		arr.push_back(Close[i]);
	}
	arr.sort();
	return arr.front();
}

double get_upper_price(int n = 5){
	DOUBLE_ARRAY arr;
	for(int i = 1; i < n; i++){
		arr.push_back(Open[i]);
		arr.push_back(Close[i]);
	}
	arr.sort();
	return arr.back();
}



void monitor()
{
	int total = MTDOrdersTotal();
	for(int i = 0; i < total; i++)
	{
		MTDOrderSelect(i, SELECT_BY_POS);
		// if(MTDOrderOpenTime() != MTDTimeCurrent())
		// {
		// 	continue;
		// }		
		int op = MTDOrderType();
		if(op != OP_BUY && op != OP_SELL)
		{
			continue;
		}
		double sl = MTDOrderStopLoss();
		if(sl != 0){
			continue;
		}
		double price = MTDOrderOpenPrice();
		double volumn = MTDOrderLots();
		int ticket = MTDOrderTicket();
		if(op == OP_BUY)
		{
			MTDOrderModify(ticket, price, price - stop_loss);
			log("Buy Stop Loss");
		}
		else if(op == OP_SELL)
		{
			MTDOrderModify(ticket, price, price + stop_loss);
			log("Sell Stop Loss");
		}
	}
}

void delete_line(){
	ObjectDelete(0, "TEST_LINE_CUR");
	ObjectDelete(0, "TEST_LINE_UP_LOSS");
	ObjectDelete(0, "TEST_LINE_DOWN_LOSS");
}

void create_line(double price){
	ObjectCreate(0, "TEST_LINE_CUR", OBJ_HLINE, 0, Time[0], price);
	ObjectSetInteger(0, "TEST_LINE_CUR", OBJPROP_COLOR, clrLimeGreen);
	ObjectCreate(0, "TEST_LINE_UP_LOSS", OBJ_HLINE, 0, Time[0], price + stop_loss);
	ObjectSetInteger(0, "TEST_LINE_UP_LOSS", OBJPROP_COLOR, clrRed);
	ObjectCreate(0, "TEST_LINE_DOWN_LOSS", OBJ_HLINE, 0, Time[0], price - stop_loss);
	ObjectSetInteger(0, "TEST_LINE_DOWN_LOSS", OBJPROP_COLOR, clrRed);
}
