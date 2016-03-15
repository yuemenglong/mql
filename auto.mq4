#property indicator_chart_window

#include "sys/context.mqh"
class Auto;

int trend = -1;
double first = 0;
double second = 0;

Auto* g(){
	return (Auto*)context();
}
double ma(){
	return iMA(Symbol(), 0, 30, 0, 0, 0, 0);
}
double top(int n){
	DOUBLE_ARRAY array;
	for(int i = 0; i < n; i++){
		array.push_back();
		array_back(array) = Open[i];
		array.push_back();
		array_back(array) = Close[i];
	}
	array.sort();
	return array_back(array);
}
double bottom(int n){
	DOUBLE_ARRAY array;
	for(int i = 0; i < n; i++){
		array.push_back();
		array_back(array) = Open[i];
		array.push_back();
		array_back(array) = Close[i];
	}
	array.sort();
	return array_front(array);
}
void fix_first(){
	switch(trend){
	case 1:
		first = MathMax(first, top(1));
		break;
	case -1:
		first = MathMin(first, bottom(1));
		break;
	}
}
void fix_second(){
	switch(trend){
	case 1:
		second = MathMin(second, bottom(1));
		break;		
	case -1:
		second = MathMax(second, top(1));
		break;
	}
}
bool break_ma(){
	return trend * (Close[0] - ma()) < 0;
}
bool break_first(){
	return trend * (Close[0] - first) > 0;
}
bool break_second(){
	return trend * (Close[0] - second) < 0;
}
bool trend_ahead(){
	return trend * (Close[0] - Close[1]) > 0;
}
bool trend_reverse(){
	return trend * (Close[0] - Close[1]) < 0;
}
bool long_bar(){
	// return MathAbs(Open[0] - Close[0]) > 0.002;
	return MathAbs(second - Close[0]) > 0.002;
}
class State
{
public:
	virtual string name(){
		return "Base";
	}
	virtual void init(){}
	virtual void on_new_bar(){}
	virtual void on_new_price(){}
};

class NormalState : public State
{
public:
	virtual string name(){
		return "Normal";
	}
	virtual void on_new_bar(){
		if(break_ma()){
			g().to_break();
		} else if(trend_reverse()){
			g().to_first();
		} else {
			fix_first();
		}
	}
};

class FirstState : public State
{
public:
	virtual string name(){
		return "First";
	}
	virtual void on_new_bar(){
		if(break_first()){
			g().to_normal();
		} else if(break_ma()){
			g().to_break();
		}
	}
};

class BreakState : public State
{
public:
	virtual string name(){
		return "Break";
	}
	virtual void on_new_bar(){
		if(trend_ahead() && long_bar()){
			g().to_long();
		} else if(trend_ahead()){
			g().to_second();
		} else {
			fix_second();
		}
	}
};

class SecondState : public State
{
public:
	virtual string name(){
		return "Second";
	}
	virtual void on_new_bar(){
		if(break_second()){
			g().to_break();
		} else if(long_bar()){
			g().to_long();
		} 
	}
};

class LongState : public State
{
public:
	virtual string name(){
		return "Long";
	}
	virtual void on_new_bar(){
		if(break_second()){
			g().to_break();
		} else{
			g().to_valid();
		}
	}
};

class ValidState : public State
{
public:
	virtual string name(){
		return "Valid";
	}
	virtual void on_new_bar(){

	}
};

class Auto : public Context
{
private:
	State* _cur;
	State* _normal;
	State* _first;
	State* _break;
	State* _second;
	State* _long;
	State* _valid;
public:
	virtual void init(){
		first = Close[0];
		second = 0;
		_normal = new NormalState();
		_first = new FirstState();
		_break = new BreakState();
		_second = new SecondState();
		_long = new LongState();
		_valid = new ValidState();

		_cur = _normal;
	}
	virtual void on_new_bar(){
		_cur.on_new_bar();
		// log("Current", _cur.name());
		// log("First", str(first));
		// log("Second", str(second));
	}
	virtual void on_key_down(int key){
		if(key == 82){
			log("State Reset");
			g().init();
		}
	}
	void to_normal(){
		log("Change To Normal");
		_cur = _normal;
	}
	void to_first(){
		log("Change To First");
		fix_first();
		_cur = _first;
	}
	void to_break(){
		log("Change To Break");
		second = Close[0];
		_cur = _break;
	}
	void to_second(){
		log("Change To Second");
		fix_second();
		_cur = _second;
	}
	void to_long(){
		log("Change To Long");
		fix_second();
		_cur = _long;
	}
	void to_valid(){
		log("Change To Valid");
		_cur = _valid;
	}
};

setup(Auto);