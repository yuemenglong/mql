#include <MTDinc.mqh>
#include "view.mqh"

class LabelBase : public View
{
protected:
	string _text;
	int _size;
	int _anchor;
public:
	LabelBase(string id, string text = "") : View(id){
		_text = text;
		_size = 15;
		_anchor = ANCHOR_CENTER;
	}
	void set_text(string text){
		_text = text;
	}
	void set_size(int size){
		_size = size;
	}
	void set_anchor(int anchor){
		_anchor = anchor;
	}
};

class Label : public LabelBase
{
private:
	int _x;
	int _y;
	int _corner;
public:
	Label(string id = "", string text = "") : LabelBase(id, text){
		_x = 0;
		_y = 0;
		_corner = CORNER_LEFT_UPPER;
		_anchor = ANCHOR_LEFT_UPPER;
	}
	void set_xy(int x, int y = 0){
		_x = x;
		_y = y;
	}
	void set_row(int row){
		_y = (int)(_size * row * 1.5);
	}
	void set_corner(int x, int y){
		if(x == 0 && y == 0){
			_corner = CORNER_LEFT_UPPER;
			_anchor = ANCHOR_LEFT_UPPER;
		}else if(x ==1 && y == 0){
			_corner = CORNER_RIGHT_UPPER;
			_anchor = ANCHOR_RIGHT_UPPER;
		}else if(x ==0 && y == 1){
			_corner = CORNER_LEFT_LOWER;
			_anchor = ANCHOR_LEFT_LOWER;
		}else if(x ==1 && y == 1){
			_corner = CORNER_RIGHT_LOWER;
			_anchor = ANCHOR_RIGHT_LOWER;
		}else{
			log("Invalid Corner");
			return;
		}
	}
	virtual void show(){
		hide();
		ObjectCreate(_id, OBJ_LABEL, 0, 0, 0);
		ObjectSetInteger(0, _id, OBJPROP_XDISTANCE, _x);
		ObjectSetInteger(0, _id, OBJPROP_YDISTANCE, _y);
		ObjectSetInteger(0, _id, OBJPROP_CORNER, _corner);
		ObjectSetString(0, _id, OBJPROP_TEXT, _text);
		ObjectSetInteger(0, _id, OBJPROP_FONTSIZE, _size);
		ObjectSetInteger(0, _id, OBJPROP_ANCHOR, _anchor);
		ObjectSetInteger(0, _id, OBJPROP_COLOR, _color);
	}
};

class Text : public LabelBase
{
private:
	datetime _time;
	double _price;
public:
	Text(string id = "", string text = "") : LabelBase(id, text){
	}
	void set_time(datetime time){
		_time = time;
	}
	void set_price(double price){
		_price = price;
	}
	virtual void show(){
		hide();
		ObjectCreate(_id, OBJ_TEXT, 0, _time, _price);
		ObjectSetString(0, _id, OBJPROP_TEXT, _text);
		ObjectSetInteger(0, _id, OBJPROP_FONTSIZE, _size);
		ObjectSetInteger(0, _id, OBJPROP_ANCHOR, _anchor);
		ObjectSetInteger(0, _id, OBJPROP_COLOR, _color);
	}
};