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
		array_push(array){
			iter(array).open_time = file.read_time();
			iter(array).type = file.read_string();
			iter(array).volumn = file.read_double();
			iter(array).symbol = file.read_string();
			iter(array).open_price = file.read_double();
			iter(array).sl = file.read_string();
			iter(array).tp = file.read_string();
			iter(array).close_time = file.read_time();
			iter(array).close_price = file.read_double();
			iter(array).commission = file.read_string();
			iter(array).swap = file.read_string();
			iter(array).profit = file.read_double();
			iter(array).comment = file.read_string();

			account += iter(array).profit;
			iter(array).account = account;

			iter(array).line.set_id("TRADE_LINE_" + str(iter(array).open_time) + str(clr));
			iter(array).line.set_from(iter(array).open_time, iter(array).open_price);
			iter(array).line.set_to(iter(array).close_time, iter(array).close_price);
			iter(array).line.set_color(clr);
			if(iter(array).profit < 0){
				iter(array).line.set_style(STYLE_DASHDOT);
			}

			iter(array).open_label.set_id("TRADE_OPEN_LABEL_" + str(iter(array).open_time) + str(clr));
			iter(array).close_label.set_id("TRADE_CLOSE_LABEL_" + str(iter(array).open_time) + str(clr));
			iter(array).open_label.set_color(clr);
			iter(array).close_label.set_color(clr);
			iter(array).open_label.set_time(iter(array).open_time);
			iter(array).open_label.set_price(iter(array).open_price + 0.005);
			iter(array).close_label.set_time(iter(array).close_time);
			iter(array).close_label.set_price(iter(array).close_price - 0.005);

			iter(array).open_label.set_text(DoubleToString(iter(array).volumn, 2));
			iter(array).close_label.set_text(DoubleToString(iter(array).profit, 2));

		}
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
		array_each(_trade_array){
			iter(_trade_array).line.show();
		}
	}
	void show_detail(){
		array_each(_trade_array){
			iter(_trade_array).open_label.show();
			iter(_trade_array).close_label.show();
		}
	}
	void hide(){
		array_each(_trade_array){
			iter(_trade_array).line.hide();
			iter(_trade_array).open_label.hide();
			iter(_trade_array).close_label.hide();
		}
	}
};