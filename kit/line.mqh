#include "view.mqh"

class Line : public View
{
private:
	datetime _start_time;
	datetime _end_time;
	double _open_price;
	double _close_price;
public:
	Line(string id) : View(id){
	}
	void set_from(datetime time, double price){
		_start_time = time;
		_open_price = price;
	}
	void set_to(datetime time, double price){
		_end_time = time;
		_close_price = price;
	}
	virtual void show(){
		hide();
		ObjectCreate(_id, OBJ_TREND, 0, _start_time, _open_price, _end_time, _close_price);
		ObjectSet(_id, OBJPROP_RAY, false);
		ObjectSetInteger(0, _id, OBJPROP_COLOR, _color);
		ObjectSetInteger(0, _id, OBJPROP_WIDTH, _width);
	}
};

class HLine : public View
{
private:
	double _price;
public:
	HLine(string id, double price) : View(id){
		_price = price;
	}
	virtual void show(){
		hide();
		ObjectCreate(_id, OBJ_HLINE, 0, 0, _price);
		ObjectSetInteger(0, _id, OBJPROP_COLOR, _color);
		ObjectSetInteger(0, _id, OBJPROP_WIDTH, _width);
	}
};

class VLine : public View
{
private:
	datetime _time;
public:
	VLine(string id, datetime time) : View(id){
		_time = time;
	}
	virtual void show(){
		hide();
		ObjectCreate(_id, OBJ_VLINE, 0, time, 0);
		ObjectSetInteger(0, _id, OBJPROP_COLOR, _color);
		ObjectSetInteger(0, _id, OBJPROP_WIDTH, _width);
	}
};