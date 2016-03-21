#include "../std/array.mqh"

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

	static double get_bar_avg_height(int count = 160){
		double total = 0;
		for(int i = 0; i < count; i++){
			total += MathAbs(Open[i] - Close[i]);
		}
		return total / count;
	}

	static double get_bar_mid_height(int count = 160){
		DOUBLE_ARRAY array;
		for(int i = 0; i < count; i++){
			array.push_back(MathAbs(Open[i] - Close[i]));
		}
		array.sort();
		return array[count/2];
	}

	static double get_bar_grid_height(int count = 160){
		DOUBLE_ARRAY array;
		for(int i = 0; i < count; i++){
			array.push_back(High[i]);
			array.push_back(Low[i]);
		}
		array.sort();
		double height = array.back() - array.front();
		return height / 40;
	}
};