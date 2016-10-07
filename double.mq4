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
#include "view/label.mqh";

extern double stop_loss = 0.005;
extern double ratio = 0.05;

double meta_stop_loss = stop_loss / 5;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

class Double : public Context
{
	double _mark_price;
	INT_ARRAY _break_array;
	Order* _last_order;
	bool _trend_flag;
	Label _trend_label;
	double _last_stop_loss;
public:
	virtual void init(){
		_trend_flag = false;
		_trend_label.set_id("DOUBLE_TREND_LABEL");	
		_trend_label.set_corner(0, 0);
		_trend_label.set_text(str(_trend_flag));
		_trend_label.show();
	}
	virtual void deinit(){
		delete_line();
		_trend_label.hide();
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
	void clear_line(){
		_mark_price = 0;
		delete_line();
	}
	void order_buy(double volumn, double sl){
		double price = _mark_price;
		if(price == 0){
			price = get_upper_price();
			if(Close[0] > price){
				log("Invalid Adjust");
				return;
			}
		}
		if(_trend_flag){
			volumn /= 2;
			sl *= 2;
			toggle_trend();
		}
		Order* order = new Order(OP_BUYSTOP, price, volumn);
		order.set_stop_loss(price - sl);
		order.send();
		_last_order = order;
		clear_line();
		log("Send Buy");
	}
	void order_sell(double volumn, double sl){
		double price = _mark_price;
		if(price == 0){
			price = get_lower_price();
			if(Close[0] < price){
				log("Invalid Adjust");
				return;
			}
		}
		if(_trend_flag){
			volumn /= 2;
			sl *= 2;
			toggle_trend();
		}
		Order* order = new Order(OP_SELLSTOP, price, volumn);
		order.set_stop_loss(price + sl);
		order.send();
		_last_order = order;
		clear_line();
		log("Send Sell");
	}
	void check_order(Order* order){
		if(!order){
			return;
		}
		int ticket = order.ticket();
		if(_break_array.find(ticket) >= 0){
			return;
		}
		if(order.type() >= 2){
			return;
		}
		if(order.type() == OP_BUY && order.open_price() > Close[0]){
			log("Not Break");
			order.close();
			Sleep(1000);
			order.send();
			log("Reopen Buy");
		} else if(order.type() == OP_SELL && order.open_price() < Close[0]){
			log("Not Break");
			order.close();
			Sleep(1000);
			order.send();
			log("Reopen Sell");
		} else{
			_break_array.push_back(ticket);
			log("Break Succ");
		}
	}
	void fix_stop_loss(){
		double open_price = _last_order.open_price();
		double sl = _last_order.stop_loss();
		if(_last_order.type() == OP_BUY){
			if(High[0] - open_price < open_price - sl){
				return;
			}
			double gap = High[0] - open_price;
			gap = get_next_stop_loss(gap);
			log("Fix To", str(gap));
			_last_order.set_stop_loss(_last_order.open_price() - gap);
			_last_order.modify();
		} else if(_last_order.type() == OP_SELL){
			if(open_price - Low[0] < sl - open_price){
				return;	
			}
			double gap = open_price - Low[0];
			log("Fix To", str(gap));
			gap = get_next_stop_loss(gap);
			_last_order.set_stop_loss(open_price + gap);
			_last_order.modify();
		}
	}
	void toggle_trend(){
		_trend_flag = _trend_flag ? false: true;
		_trend_label.set_text(str(_trend_flag));
		_trend_label.show();
	}
	void toggle_stop_loss(){
		if(!_last_order){
			return;
		}
		double sl = _last_order.stop_loss();
		log(sl);
		if(sl > 0){
			_last_stop_loss = sl;
			_last_order.set_stop_loss(0);
			_last_order.modify();	
		}else{
			_last_order.set_stop_loss(_last_stop_loss);
			_last_order.modify();
		}
	}
	virtual void on_key_down(int key){
		// stop_loss = get_shad_avg_height(1.3) + get_shad_mid_height(0.75);
		// stop_loss = get_k_mid_height(30, 0.7);
		log(str(key));
		double volumn = MTDAccountBalance() * ratio / (stop_loss * 100000);
		if(key == 66){
			order_buy(volumn, stop_loss);
		}
		if(key == 83){
			order_sell(volumn, stop_loss);	
		}
		if(key == 84){
			// toggle_trend();
		}
		if(key == 67){//check
			check_order(_last_order);
		}
		if(key == 82){//resend
			if(_last_order){
				_last_order.send();
				log("Resend");
			}
		}
		if(key == 68){//del
			toggle_stop_loss();
		}
		if(key == 70){//fix
			fix_stop_loss();
		}
	}
};
setup(Double);

double get_next_stop_loss(double gap){
	double ret = meta_stop_loss;
	while(true){
		if(ret >= stop_loss){
			return stop_loss;
		}
		if(ret > gap){
			return ret;
		}
		ret += meta_stop_loss;
	}
	return stop_loss;
}

double get_lower_price(int n = 10){
	DOUBLE_ARRAY arr;
	for(int i = 1; i < n; i++){
		arr.push_back(Open[i]);
		arr.push_back(Close[i]);
	}
	arr.sort();
	return arr.front();
}

double get_upper_price(int n = 10){
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
