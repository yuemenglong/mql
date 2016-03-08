#include <MTDinc.mqh>
#include "./log.mqh"

class ContextBase 
{
private:
	string _name;
public:
	ContextBase(string name = "Context Base");
	void set_name(string name);

	int get_width();
	int get_height();
	datetime get_time(int x);
	double get_price(int y);
	int get_x(datetime time);
	int get_y(double price);

	virtual void on_click(int x, int y);
	virtual void on_double_click(int x, int y);
	virtual void on_key_down(int key);
	virtual void on_mouse_move(int x, int y);

	virtual int init();
	virtual int deinit();
	virtual int start();
};

ContextBase* _context = NULL;

ContextBase* context(){
	return _context;
}

#define setup(T) \
int init() \
{ \
	_context = new T(); \
	_context.set_name(#T); \
	_context.init(); \
	return 0; \
} \

void ContextBase::ContextBase(string name){
	_name = name;
}

void ContextBase::set_name(string name){
	_name = name;
}

int start()
{
	_context.start();
	return 0;
}

int deinit()
{
	_context.deinit();
	return 0;
}

bool is_double_click(const int id, const long& lparam, const double& dparam, const string& sparam){
	static uint _last_click = 0;
	if(id == CHARTEVENT_CLICK){
		uint now = GetTickCount();
		if(now - _last_click < 200){
			_last_click = 0;
			return true;
		}else{
			_last_click = now;
			return false;
		}
	}
	else{
		return false;
	}
}

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam){
	if(is_double_click(id, lparam,dparam,sparam)){
		_context.on_double_click((int)lparam, (int)dparam);
	}
	if(id == CHARTEVENT_CLICK){
		_context.on_click((int)lparam, (int)dparam);
	}
	if(id == CHARTEVENT_KEYDOWN){
		_context.on_key_down((int)lparam);
	}
	if(id == CHARTEVENT_MOUSE_MOVE){
		_context.on_mouse_move((int)lparam, (int)dparam);
	}
}

int ContextBase::init(){
	log(_name, "Init");
	return 0;
}

int ContextBase::deinit(){
	log(_name, "Deinit");
	return 0;
}

int ContextBase::start(){
	return 0;
}

int ContextBase::get_width(){
	int width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
	return width;
}

int ContextBase::get_height(){
	int height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);
	return height;
}

void ContextBase::on_click(int x, int y){
	return;
}

void ContextBase::on_double_click(int x, int y){
	return;
}

void ContextBase::on_key_down(int key){
	return;
}

void ContextBase::on_mouse_move(int x, int y){
	return;
}

datetime ContextBase::get_time(int x){
	datetime time;
	double price;
	int sub_window;
	ChartXYToTimePrice(0, x, 0, sub_window, time, price);
	return time;
}

double ContextBase::get_price(int y){
	datetime time;
	double price;
	int sub_window;
	ChartXYToTimePrice(0, 0, y, sub_window, time, price);
	return price;
}

int ContextBase::get_x(datetime time){
	int sub_window = 0;
	int x, y;
	ChartTimePriceToXY(0, sub_window, time, Close[0], x, y);
	return x;
}

int ContextBase::get_y(double price){
	int sub_window = 0;
	int x, y;
	ChartTimePriceToXY(0, sub_window, Time[0], price, x, y);
	return y;
}

