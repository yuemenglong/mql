#property indicator_chart_window

#include <MTDinc.mqh>
#include "kit/log.mqh";
#include "kit/kit.mqh";
#include "sys/trade.mqh";
#include "view/label.mqh";

string TEXT = "Save(S)/Refresh(R)/Delete(D)/Mode(M)";

class Stock : public Trade
{
	int _order;
	Label* _label;
	bool _auto;
	bool _save_flag;
	int _trend;
public:
	virtual void init(){
		_order = -1;
		_auto = false;
		_save_flag = false;
		_trend = 0;
		_label = new Label("STOCK_SAVE_LABEL");
		_label.set_corner(0, 1);
		_label.set_row(1);
		show_label();	
	}
	virtual void deinit(){
		order_clear();
		_label.hide();
	}
	void open(){
		if(_order != -1){
			log("Order Exists");
			return;
		}
		_order = order_buy();
		log("Order Open");
	}
	void close(){
		if(_order == -1){
			log("Order Not Exists");
			return;
		}
		order_close(_order);
		_order = -1;
		log("Order Close");
	}
	void save(){
		order_save();
		_save_flag = true;
		log("Save Trade Succ");
	}
	void show_label(){
		string mode = _auto ? " [AUTO]" : " [MANUAL]";
		string save = _save_flag ? " [Save Succ]" : "";
		_label.set_text(TEXT + mode + save);
		_label.show();
	}
	void switch_mode(){
		_auto = !_auto;
	}
	virtual void on_new_bar(){
		if(!_auto){
			return;
		}
		if(_order == -1 && ema(6) > ema(18)){
			// && ema(6) > ema(108) && _trend == -1
			open();
		}else if(_order != -1 && ema(6) < ema(18)){
			close();
		}
		_trend = ema(6) > ema(18) ? 1 : -1;
	}
	virtual void on_key_down(int key){
		log(str(key));
		_save_flag = false;
		if(key == 66){//buy
			open();
		}else if(key == 67){//close
			close();
		}else if(key == 68){//delete
			order_delete_last();
		}else if(key == 82){//refresh
			order_clear();
		}else if(key == 77){//switch mode
			switch_mode();
		}else if(key == 83){//save
			save();
		}
		show_label();
	}
};
setup(Stock);
