double _mouse_price = 0;
datetime _mouse_time;

void mouse_move(const int id,
	const long & lparam,
	const double & dparam,
	const string & sparam)
{
	if (id == CHARTEVENT_MOUSE_MOVE) {
		int x = (int) lparam;
		int y = (int) dparam;
		int sub_window;
		ChartXYToTimePrice(0, x, y, sub_window, _mouse_time, _mouse_price);
		_mouse_price = (int)(_mouse_price * 100000) / 100000.0;
	}
}

double mouse_price(){
	return _mouse_price;
}

datetime mouse_time(){
	return _mouse_time;
}