#property indicator_chart_window

#include "sys/context.mqh"
#include "view/label.mqh"
#include "view/line.mqh"

#define MAX 8192

string PREFIX = "PAINT_PREFIX_";

class point_t 
{
public:
	datetime time;
	double price;
};

class Paint : public Context
{
   bool _paint;
   Label* _paint_label;
   Line* _cur_line;
   int _cur_no;
public:
	virtual void init(){
		enable_mouse_move();
		_paint = false;
		_cur_no = 0;
		_paint_label = new Label("PAINT_LABEL");
		_paint_label.set_corner(1, 0);
		show_label();
	}
	virtual void deinit(){
		_paint_label.hide();
		delete_object_prefix(PREFIX);
	}
	void show_label(){
		_paint_label.set_text("PAINT: " + str(_paint));
		_paint_label.show();
	}
	virtual void on_click(int x, int y){
		if(!_paint){
			return;
		}
		if(!_cur_line){
			_cur_line = new Line(PREFIX + _cur_no);
			_cur_line.set_from(get_time(x), get_price(y));
		} else {
			_cur_line.set_to(get_time(x), get_price(y));
			_cur_line.show();
			_cur_no++;
			_cur_line.set_id(PREFIX + _cur_no);
			_cur_line.set_from(get_time(x), get_price(y));
		}
	}
	virtual void on_mouse_move(int x, int y){
		if(!_paint || !_cur_line){
			return;
		}
		_cur_line.set_to(get_time(x), get_price(y));
		_cur_line.show();
	}
	void swtch(){
		_paint = !_paint;
		show_label();
		if(!_paint && _cur_line != NULL){
			_cur_line.hide();
			delete _cur_line;
			_cur_line = NULL;
		}
	}
	void delete_last(){
		if(_paint){
			swtch();
		}
		ObjectDelete(PREFIX + _cur_no);
		if(_cur_no > 0){
			_cur_no--;
		}
	}
	virtual void on_key_down(int key){
		if(key == 80){
			swtch();
		} else if(key == 219){
			delete_last();
		}
	}
};

setup(Paint);

