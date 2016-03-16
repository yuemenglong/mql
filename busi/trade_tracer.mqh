#include "../std/array.mqh";
#include "../std/file.mqh";
#include "../view/line.mqh";
#include "../view/label.mqh";
#include "../kit/kit.mqh";
#include "../std/array.mqh";
#include "../sys/context.mqh";

class trade_data_t : public ArrayItem
{
public:
	datetime open_time;
	datetime close_time;
	double open_price;
	double close_price;	
	double volumn;
	double profit;
	string type;
	string symbol, sl, tp, commission, swap, comment;

	double account;

	Line line;
	Text open_label;
	Text close_label;
};

ARRAY_DEFINE(trade_data_t, TRADE_ARRAY);

void get_trade_from_csv(string path, int clr, TRADE_ARRAY& array){
	File file(path);
	file.read_line();
	file.read_line();
	double account = 2000;
	while(!file.reach_end()){
		trade_data_t* data = new trade_data_t();
		data.open_time = file.read_time();
		data.type = file.read_string();
		data.volumn = file.read_double();
		data.symbol = file.read_string();
		data.open_price = file.read_double();
		data.sl = file.read_string();
		data.tp = file.read_string();
		data.close_time = file.read_time();
		data.close_price = file.read_double();
		data.commission = file.read_string();
		data.swap = file.read_string();
		data.profit = file.read_double();
		data.comment = file.read_string();

		account += data.profit;
		data.account = account;

		data.line.set_id("TRADE_LINE_" + str(data.open_time) + str(clr));
		data.line.set_from(data.open_time, data.open_price);
		data.line.set_to(data.close_time, data.close_price);
		data.line.set_color(clr);
		if(data.profit < 0){
			data.line.set_style(STYLE_DASHDOT);
		}

		data.open_label.set_id("TRADE_OPEN_LABEL_" + str(data.open_time) + str(clr));
		data.close_label.set_id("TRADE_CLOSE_LABEL_" + str(data.open_time) + str(clr));
		data.open_label.set_color(clr);
		data.close_label.set_color(clr);
		data.open_label.set_time(data.open_time);
		data.open_label.set_price(data.open_price + 0.005);
		data.close_label.set_time(data.close_time);
		data.close_label.set_price(data.close_price - 0.005);

		data.open_label.set_text(DoubleToString(data.volumn, 2));
		data.close_label.set_text(DoubleToString(data.profit, 2));

		array.push_back(data);
	}	
	file.close();
}


class TradeTracer
{
private:
	TRADE_ARRAY _trade_array;
public:
	TradeTracer(string path, int clr){
		get_trade_from_csv(path, clr, _trade_array);
	}
	void show(){
		show_line();
		show_detail();
	}
	void show_line(){
		for(int i = 0; i < _trade_array.size(); i++){
			_trade_array[i].line.show();
		}
	}
	void show_detail(){
		for(int i = 0; i < _trade_array.size(); i++){
			_trade_array[i].open_label.show();
			_trade_array[i].close_label.show();
		}
	}
	void hide(){
		for(int i = 0; i < _trade_array.size(); i++){
			_trade_array[i].line.hide();
			_trade_array[i].open_label.hide();
			_trade_array[i].close_label.hide();
		}
	}
};