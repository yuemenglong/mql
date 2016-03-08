#include <MTDinc.mqh>

class Label
{
private:
	string _id;
	string _text;
	int _x;
	int _y;
	int _size;
	int _color;
	int _corner;

public:
	Label(string id, string text = "");
	void set_xy(int x, int y);
	void set_size(int size);
	void set_color(int clr);
	void set_corner(int corner);
	void set_text(string text);

	void show();
	void hide();
};

Label::Label(string id, string text)
{
	_id = id;
	_text = text;
	_x = 0;
	_y = 0;
	_size = 10;
	_color = Lime;
	_corner = 0;
}

void Label::set_xy(int x, int y)
{
	_x = x;
	_y = y;
}

void Label::set_size(int size)
{
	_size = size;
}

void Label::set_color(int clr)
{
	_color = clr;
}

void Label::set_corner(int corner)
{
	_corner = corner;
}

void Label::set_text(string text)
{
	_text = text;
}

void Label::show()
{
	hide();
	MTDlabel(_id, _text, _color, _size, _x, _y, _corner);
}

void Label::hide()
{
	ObjectDelete(_id);
}