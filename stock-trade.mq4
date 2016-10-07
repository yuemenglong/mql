#property indicator_chart_window

#include <MTDinc.mqh>
#include "kit/log.mqh";
#include "kit/kit.mqh";
#include "sys/trade.mqh";
#include "view/label.mqh";

class Stock : public Trade
{
	int _order;
	Label* _label;
public:
	virtual void init(){
		_order = -1;
		_label = new Label("STOCK_SAVE_LABEL");
		_label.set_text("Save Orders(S)/Refresh(R)");
		_label.set_corner(0, 1);
		_label.set_row(1);
		_label.show();
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
	}
	virtual void on_key_down(int key){
		_label.set_text("Save Orders(S)/Refresh(R)");
		log(str(key));
		if(key == 66){
			open();
		}
		if(key == 67){//check
			close();
		}
		if(key == 68){//check
			order_delete_last();
		}
		if(key == 82){//refresh
			order_clear();
		}
		if(key == 83){//save
			save();
			_label.set_text("Save Orders(S) Succ");
		}
		_label.show();
	}
};
setup(Stock);
