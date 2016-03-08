class View
{
protected:
	string _id;
	int _color;
	int _size;
	int _width;
public:
	View(string id);
	string id();
	void set_color(int clr);
	void set_size(int size);
	void set_width(int width);
	virtual void show();
	virtual void hide();
};

View::View(string id){
	_id = id;
	_size = 10;
	_width = 1;
	_color = Lime;
}

string View::id(){
	return _id;
}

void View::set_color(int clr){
	_color = clr;
}

void View::set_size(int size){
	_size = size;
}

void View::set_width(int width){
	_width = width;
}

void View::show(){
	hide();
}

void View::hide(){
	ObjectDelete(_id);
}