#include "view.mqh"

class LineBase : public View
{
protected:
	int _width;
	int _style;
public:
	void LineBase(string id) : View(id){
		_width = 1;
		_style = STYLE_SOLID;
	}
	void set_width(int width){
		_width = width;
	}
	void set_style(int style){
		_style = style;
	}
};

class Line : public LineBase
{
private:
	datetime _start_time;
	datetime _end_time;
	double _open_price;
	double _close_price;
public:
	Line(string id = "") : LineBase(id){}
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
		ObjectSetInteger(0, _id, OBJPROP_STYLE, _style);
	}
};

class HLine : public LineBase
{
private:
	double _price;
public:
	HLine(string id = "") : LineBase(id){}
	void set_price(double price){
		_price = price;
	}
	virtual void show(){
		hide();
		ObjectCreate(_id, OBJ_HLINE, 0, 0, _price);
		ObjectSetInteger(0, _id, OBJPROP_COLOR, _color);
		ObjectSetInteger(0, _id, OBJPROP_WIDTH, _width);
		ObjectSetInteger(0, _id, OBJPROP_STYLE, _style);
	}
};

class VLine : public LineBase
{
private:
	datetime _time;
public:
	VLine(string id = "") : LineBase(id){}
	void set_time(datetime time){
		_time = time;
	}
	virtual void show(){
		hide();
		ObjectCreate(_id, OBJ_VLINE, 0, _time, 0);
		ObjectSetInteger(0, _id, OBJPROP_COLOR, _color);
		ObjectSetInteger(0, _id, OBJPROP_WIDTH, _width);
		ObjectSetInteger(0, _id, OBJPROP_STYLE, _style);
	}
};