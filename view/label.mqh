#include <MTDinc.mqh>
#include "view.mqh"

class Label : public View
{
private:
	string _text;
	int _size;
	int _x;
	int _y;
	int _corner;
	int _anchor;
public:
	Label(string id = "", string text = "") : View(id){
		_text = text;
		_size = 15;
		_x = 0;
		_y = 0;
		_corner = CORNER_LEFT_UPPER;
	}
	void set_xy(int x, int y = 0){
		_x = x;
		_y = y;
	}
	void set_row(int row){
		_y = (int)(_size * row * 1.5);
	}
	void set_corner(int corner){
		_corner = corner;
		switch(corner){
		case CORNER_LEFT_UPPER:
			_anchor = ANCHOR_LEFT_UPPER;
			break;
		case CORNER_LEFT_LOWER:
			_anchor = ANCHOR_LEFT_LOWER;
			break;
		case CORNER_RIGHT_UPPER:
			_anchor = ANCHOR_RIGHT_UPPER;
			break;
		case CORNER_RIGHT_LOWER:
			_anchor = ANCHOR_RIGHT_LOWER;
			break;
		}
	}
	void set_anchor(int anchor){
		_anchor = anchor;
	}
	void set_text(string text){
		_text = text;
	}
	void set_size(int size){
		_size = size;
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
