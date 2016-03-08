#include <MTDinc.mqh>

bool IsDoubleClick(const int id,         
	const long& lparam,   
	const double& dparam, 
	const string& sparam  
	)
{
	static uint _last_click = 0;
	if(id == CHARTEVENT_CLICK){
		uint now = GetTickCount();
		if(now - _last_click < 200){
			_last_click = 0;
			return true;
		}else{
			_last_click = now;
			return false;
		}
	}
	else{
		return false;
	}
}

datetime event_time(const int id,          
  const long& lparam,    
  const double& dparam, 
  const string& sparam   
  )
{
	int x = (int)lparam;
	int y = (int)dparam;
	datetime time;
	double price;
	int sub_window;
	ChartXYToTimePrice(0, x, y, sub_window, time, price);
	return time;	
}

double event_price(const int id,          
  const long& lparam,    
  const double& dparam, 
  const string& sparam   
  )
{
	int x = (int)lparam;
	int y = (int)dparam;
	datetime time;
	double price;
	int sub_window;
	ChartXYToTimePrice(0, x, y, sub_window, time, price);
	price = (int)(price * 100000) / 100000.0;
	return price;
}

void line(string name, datetime x1, double y1, datetime x2, double y2, int clr = clrBlue, int width = 2)
{
	ObjectCreate(name, OBJ_TREND, 0, x1, y1, x2, y2);
	ObjectSet(name, OBJPROP_RAY, false);
	ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
	ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
}

void label(string name, string text, int row, int corner = 0, int clr = Lime)
{
	MTDlabel(name, text, clr, 20, 10, 30 * row + 10, corner);
}

double normalise(double price){
	return (int)(price * 100000) / 100000.0;
}