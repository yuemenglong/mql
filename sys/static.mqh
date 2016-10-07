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

	static double get_grid_height(int count = 160){
		DOUBLE_ARRAY array;
		for(int i = 0; i < count; i++){
			array.push_back(High[i]);
			array.push_back(Low[i]);
		}
		array.sort();
		double height = array.back() - array.front();
		return height / 40;
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

	static double get_k_avg_height(double fix = 1.0){
		return get_k_avg_height(160, fix);
	}

	static double get_k_avg_height(int count, double fix){
		double total = 0;
		for(int i = 0; i < count; i++){
			double k = High[i] - Low[i];
			total += k;
		}
		return total / count * fix;
	}

	static double get_k_mid_height(double r = 0.5){
		return get_k_mid_height(160, r);
	}

	static double get_k_mid_height(int count, double r){
		DOUBLE_ARRAY array;
		for(int i = 0; i < count; i++){
			double k = High[i] - Low[i];
			array.push_back(MathAbs(k));
		}
		array.sort();
		return array[(int)(count*r)];
	}

	static double get_shad_avg_height(double fix = 1.0){
		return get_shad_avg_height(160, fix);
	}

	static double get_shad_avg_height(int count, double fix){
		double total = 0;
		for(int i = 0; i < count; i++){
			double shad = High[i] - Low[i] - MathAbs(Open[i] - Close[i]);
			total += shad;
		}
		return total / count * fix;
	}

	static double get_shad_mid_height(double r = 0.5){
		return get_shad_mid_height(160, r);
	}

	static double get_shad_mid_height(int count, double r){
		DOUBLE_ARRAY array;
		for(int i = 0; i < count; i++){
			double shad = High[i] - Low[i] - MathAbs(Open[i] - Close[i]);
			array.push_back(MathAbs(shad));
		}
		array.sort();
		return array[(int)(count*r)];
	}

	static double ma(int cycle, int i=0, int prev=0) {
		return iMA(NULL, 0, cycle, prev, MODE_SMA, PRICE_CLOSE, i);
	}

	static double ema(int cycle, int i=0, int prev=0) {
		return iMA(NULL, 0, cycle, prev, MODE_EMA, PRICE_CLOSE, i);
	}


};