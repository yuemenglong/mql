#property indicator_chart_window

#include <MTDinc.mqh>
#include "../kit/log.mqh";
#include "../kit/kit.mqh";
#include "../kit/proc.mqh";
#include "../view/label.mqh";
#include "trade.mqh";

string TEXT = "Save(S)/Load(L)/Delete(D)/Clear(R)/Analyze(A)/Mode(M)";

class Auto : public Trade
{
	int _order;
	Label* _label;
	bool _auto;
public:
	virtual void init(){
		_order = -1;
		_auto = false;
		_label = new Label("STOCK_MANUAL_LABEL");
		_label.set_corner(0, 1);
		_label.set_row(1);
		show_label();	
	}
	virtual void deinit(){
		order_clear();
		_label.hide();
	}
	virtual void exec(){

	}
	bool auto_opened(){
		return _order != -1;
	}
	void auto_buy(){
		if(auto_opened()){
			log("Order Exists");
			return;
		}
		_order = order_buy();
		log("Order Open");
	}
	void auto_close(){
		if(!auto_opened()){
			log("Order Not Exists");
			return;
		}
		order_close(_order);
		_order = -1;
		log("Order Close");
	}
private:
	void delete_last(){
		order_delete_last();
		_order = -1;
	}
	void save(){
		order_save();
		log("Save Trade Succ");
	}
	void load(){
		order_load();
		log("Load Trade Succ");
	}
	void clear(){
		_order = -1;		
		order_clear();
	}
	void show_label(){
		string mode = _auto ? " [AUTO]" : " [MANUAL]";
		_label.set_text(TEXT + mode);
		_label.show();
	}
	void switch_mode(){
		_auto = !_auto;
	}
	void analyze(){
		save();
		string param = "analyze -- " + Symbol();
		Process::node(param);
	}
public:
	virtual void on_new_bar(){
		if(!_auto){
			return;
		}
		//special case
		if(auto_opened() && (Close[0] < 0.8 * Close[1] || Close[0] > 1.2 * Close[1])){
			order_close(_order, Close[1]);
			_order = -1;
			return;
		}
		exec();
	}
	virtual void on_key_down(int key){
		log(str(key));
		if(key == 66){//buy
			auto_buy();
		}else if(key == 67){//close
			auto_close();
		}else if(key == 68){//delete
			delete_last();
		}else if(key == 82){//clear
			clear();
		}else if(key == 77){//switch mode
			switch_mode();
		}else if(key == 83){//save
			save();
		}else if(key == 76){//save
			load();
		}else if(key == 65){//analyze
			analyze();
		}
		show_label();
	}	
};
