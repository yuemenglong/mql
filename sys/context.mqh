#include <MTDinc.mqh>
#include "../kit/log.mqh"
#include "../std/array.mqh"
#include "../std/file.mqh"
#include "static.mqh"
#include "order_event_manager.mqh"

class Context;

class ContextOrderEventListener : public OrderEventListener
{
	Context* _context;
public:
	ContextOrderEventListener(Context* context){
		_context = context;
	}
	virtual void on_order_pending(Order* order){
		_context.on_order_pending(order);
	}
	virtual void on_order_open(Order* order){
		_context.on_order_open(order);
	}
	virtual void on_order_close(Order* order){
		_context.on_order_close(order);
	}
	virtual void on_order_delete(Order* order){
		_context.on_order_delete(order);
	}
};

class Context : public Static
{
private:
	string _name;
	datetime _last_time;
	int _cursor_x;
	int _curosr_y;
	OrderEventListener* _listener;
public:
	Context(string name = "Context Base");
	void set_name(string name);
	string get_name();

	void enable_mouse_move();
	int get_cursor_x();
	int get_cursor_y();
	datetime get_cursor_time();
	double get_cursor_price();
	void _on_mouse_move(int x, int y);

	virtual void on_click(int x, int y);
	virtual void on_right_click(int x, int y);
	virtual void on_double_click(int x, int y);
	virtual void on_key_down(int key);
	virtual void on_mouse_move(int x, int y);

	virtual void on_new_bar();
	virtual void on_new_price();

	void enable_order_event();
	virtual void on_order_pending(Order* order);
	virtual void on_order_open(Order* order);
	virtual void on_order_close(Order* order);
	virtual void on_order_delete(Order* order);

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
	if(_listener){
		_order_event_manager.start();
	}
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
		_on_mouse_move((int)lparam, (int)dparam);
	}
}

#define setup(T) \
Context* _context = NULL; \
Context* context(){ \
	return _context; \
} \
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

void Context::_on_mouse_move(int x, int y){
	_cursor_x = x;
	_curosr_y = y;
	on_mouse_move(x, y);
}

int Context::get_cursor_x(){
	return _cursor_x;
}

int Context::get_cursor_y(){
	return _curosr_y;
}

datetime Context::get_cursor_time(){
	return get_time(_cursor_x);
}

double Context::get_cursor_price(){
	return get_price(_curosr_y);
}

void Context::on_click(int x, int y){
	return;
}

void Context::on_right_click(int x, int y){
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

void Context::enable_order_event(){
	_listener = new ContextOrderEventListener(&this);
	_order_event_manager.set_listener(_listener);
}

void Context::on_order_pending(Order* order){
	return;	
}
void Context::on_order_open(Order* order){
	return;	
}
void Context::on_order_close(Order* order){
	return;	
}
void Context::on_order_delete(Order* order){
	return;	
}

