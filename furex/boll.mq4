//+------------------------------------------------------------------+
//|                                                         boll.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#include <MTDinc.mqh>
#include "kit/log.mqh";
#include "kit/kit.mqh";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
	log("Init");
	return 0;
}

int deinit()
{
	log("Deinit");
	return 0;
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
	// double  iBands(
 //   string       symbol,           // symbol
 //   int          timeframe,        // timeframe
 //   int          period,           // averaging period
 //   double       deviation,        // standard deviations
 //   int          bands_shift,      // bands shift
 //   int          applied_price,    // applied price
 //   int          mode,             // line index
 //   int          shift             // shift
 //   );
	// double bands = iBands(Symbol(), 0, 20, 2, 0, PRICE_CLOSE, 0, 0);
	// void MTDlabel(string id="id",string text="",color fontcolor=Lime,int fontsize=20, int x=66, int y=66,int myCorner=0);
	// MTDlabel("BANDS", str(bands), clrGreen);
	drawRatio(1);
	drawRatio(2);
	log(str(averageBarLength()), str(MathAbs(Open[0] - Close[0])));
	return 0;
}

double averageBarLength()
{
	double total = 0.0;	
	for(int i = 0; i < 160; i++)
	{
		total += MathAbs(Open[i] - Close[i]);
	}
	return total / 160.0;
}

void drawRatio(int mode) //1 upper 2 lower
{
	double pre = iBands(Symbol(), 0, 20, 2, 0, PRICE_CLOSE, mode, 1);
	double cur = iBands(Symbol(), 0, 20, 2, 0, PRICE_CLOSE, mode, 0);
	double gap = MathAbs((cur - pre) * 10000);
	MTDlabel(StringConcatenate("BANDS", str(mode)), str(gap), 
		clrLime, 20, 10, -20 + 30 * mode);
}
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         
  const long& lparam,   
  const double& dparam, 
  const string& sparam  
  )
{
    if(IsDoubleClick(id, lparam,dparam,sparam)){
        DoubleClick(id, lparam, dparam, sparam);
    }
}

void DoubleClick(const int id,         
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
    double gap = MathAbs(price - Close[0]);
    double volume = MTDAccountBalance() * 0.05 / (gap * 100000);
    if(price > Close[0])
    {
    	//sell	
    	MTDOrderSend(Symbol(), OP_SELL, volume, Close[0], 0, Close[0] + gap);
    	log("Sell");
    }
    else
    {
    	//buy
    	MTDOrderSend(Symbol(), OP_BUY, volume, Close[0], 0, Close[0] - gap);
    	log("Buy");
    }
}