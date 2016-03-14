#include <MTDinc.mqh>
#include "./log.mqh"

class Context 
{
private:
	string _name;
	datetime _last_time;
public:
	Context(string name = "Context Base");
	void set_name(string name);
	string get_name();

	static int get_width();
	static int get_height();
	static datetime get_time(int x);
	static double get_price(int y);
	static int get_x(datetime time);
	static int get_y(double price);

	void enable_mouse_move();

	virtual void on_click(int x, int y);
	virtual void on_double_click(int x, int y);
	virtual void on_key_down(int key);
	virtual void on_mouse_move(int x, int y);
	virtual void on_new_bar();
	virtual void on_new_price();

	virtual void init();
	virtual void deinit();
	virtual void start();

	void _on_init();
	void _on_start();
	void _on_deinit();
	void _on_chart_event(const int id, const long& lparam, const double& dparam, const string& sparam);
};

void Context::Context(string name){
	_name = name;
}

void Context::set_name(string name){
	_name = name;
}

string Context::get_name(){
	return _name;
}

void Context::_on_init(){
	log(get_name(), "Init");
	init();
}

void Context::_on_start(){
	if(Time[0] == _last_time){
		on_new_price();
	}else{
		_last_time = Time[0];
		on_new_bar();
	}
	start();
}

void Context::_on_deinit(){
	log(get_name(), "Deinit");
	deinit();
}

void Context::_on_chart_event(const int id, const long& lparam, const double& dparam, const string& sparam){
	if(is_double_click(id, lparam,dparam,sparam)){
		on_double_click((int)lparam, (int)dparam);
	}
	if(id == CHARTEVENT_CLICK){
		on_click((int)lparam, (int)dparam);
	}
	if(id == CHARTEVENT_KEYDOWN){
		on_key_down((int)lparam);
	}
	if(id == CHARTEVENT_MOUSE_MOVE){
		on_mouse_move((int)lparam, (int)dparam);
	}
}

#define setup(T) \
Context* _context = NULL; \
int init() \
{ \
	_context = new T(); \
	_context.set_name(#T); \
	_context._on_init(); \
	return 0; \
} \
int start() \
{ \
	_context._on_start(); \
	return 0; \
} \
int deinit() \
{ \
	_context._on_deinit(); \
	return 0; \
} \
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam){ \
	_context._on_chart_event(id, lparam, dparam, sparam); \
} \

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

void Context::init(){
}

void Context::deinit(){
}

void Context::start(){
}

void Context::enable_mouse_move(){
	ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 0, true);
}

int Context::get_width(){
	int width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
	return width;
}

int Context::get_height(){
	int height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);
	return height;
}

void Context::on_click(int x, int y){
	return;
}

void Context::on_double_click(int x, int y){
	return;
}

void Context::on_key_down(int key){
	return;
}

void Context::on_mouse_move(int x, int y){
	return;
}

void Context::on_new_bar(){
	return;
}

void Context::on_new_price(){
	return;
}

datetime Context::get_time(int x){
	datetime time;
	double price;
	int sub_window;
	ChartXYToTimePrice(0, x, 0, sub_window, time, price);
	return time;
}

double Context::get_price(int y){
	datetime time;
	double price;
	int sub_window;
	ChartXYToTimePrice(0, 0, y, sub_window, time, price);
	return price;
}

int Context::get_x(datetime time){
	int sub_window = 0;
	int x, y;
	ChartTimePriceToXY(0, sub_window, time, Close[0], x, y);
	return x;
}

int Context::get_y(double price){
	int sub_window = 0;
	int x, y;
	ChartTimePriceToXY(0, sub_window, Time[0], price, x, y);
	return y;
}

