#include <MTDinc.mqh>
#include "view.mqh"

class Label : public View
{
private:
	string _text;
	int _x;
	int _y;
	int _corner;

public:
	Label(string id, string text = "");
	void set_xy(int x, int y);
	void set_corner(int corner);
	void set_text(string text);

	virtual void show();
};

Label::Label(string id, string text)
: View(id)
{
	_text = text;
	_x = 0;
	_y = 0;
	_corner = 0;
}

void Label::set_xy(int x, int y)
{
	_x = x;
	_y = y;
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

