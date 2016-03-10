class View
{
protected:
	string _id;
	int _color;
public:
	View(string id = "");
	void set_id(string id);
	void set_color(int clr);
	virtual void show();
	virtual void hide();
};

View::View(string id){
	_id = id;
	_color = Lime;
}

void View::set_id(string id){
	_id = id;
}

void View::set_color(int clr){
	_color = clr;
}

void View::show(){
	hide();
}

void View::hide(){
	ObjectDelete(_id);
}