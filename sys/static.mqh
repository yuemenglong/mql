class Static
{
public:
	static int get_width(){
		int width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
		return width;
	}

	static int get_height(){
		int height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);
		return height;
	}

	static datetime get_time(int x){
		datetime time;
		double price;
		int sub_window;
		ChartXYToTimePrice(0, x, 0, sub_window, time, price);
		return time;
	}

	static double get_price(int y){
		datetime time;
		double price;
		int sub_window;
		ChartXYToTimePrice(0, 0, y, sub_window, time, price);
		return price;
	}

	static int get_x(datetime time){
		int sub_window = 0;
		int x, y;
		ChartTimePriceToXY(0, sub_window, time, Close[0], x, y);
		return x;
	}

	static int get_y(double price){
		int sub_window = 0;
		int x, y;
		ChartTimePriceToXY(0, sub_window, Time[0], price, x, y);
		return y;
	}

};