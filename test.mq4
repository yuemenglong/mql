//+------------------------------------------------------------------+
//|                                                       布林线.mq4 |
//+------------------------------------------------------------------+
#property  copyright "复盘专家"

#include "kit/kit.mqh"
#include "kit/log.mqh"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Aqua
#property indicator_color2 Aqua
#property indicator_color3 Aqua
//---- indicator parameters
extern int    BandsPeriod=35;//时间周期
extern int    BandsShift=0;//平移
extern double BandsDeviations=2.0;//偏差
//---- buffers
double MovingBuffer[];
double UpperBuffer[];
double LowerBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE,0,1);
   SetIndexBuffer(0,MovingBuffer);
   SetIndexStyle(1,DRAW_LINE,2,1);
   SetIndexBuffer(1,UpperBuffer);
   SetIndexStyle(2,DRAW_LINE,2,1);
   SetIndexBuffer(2,LowerBuffer);
//----
   SetIndexDrawBegin(0,BandsPeriod+BandsShift);
   SetIndexDrawBegin(1,BandsPeriod+BandsShift);
   SetIndexDrawBegin(2,BandsPeriod+BandsShift);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Bollinger Bands                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int    i,k,counted_bars=IndicatorCounted();
   double deviation;
   double sum,oldval,newres;
//----
   if(Bars<=BandsPeriod) return(0);
//---- initial zero
   if(counted_bars<1)
      for(i=1;i<=BandsPeriod;i++)
        {
         MovingBuffer[Bars-i]=EMPTY_VALUE;
         UpperBuffer[Bars-i]=EMPTY_VALUE;
         LowerBuffer[Bars-i]=EMPTY_VALUE;
        }
//----
   int limit=Bars-counted_bars;
   if(counted_bars>0) limit++;
   for(i=0; i<limit; i++)
      MovingBuffer[i]=iMA(NULL,0,BandsPeriod,BandsShift,MODE_SMA,PRICE_CLOSE,i);
//----
   i=Bars-BandsPeriod+1;
   i=0;
   if(counted_bars>BandsPeriod-1) i=Bars-counted_bars-1;
   while(i>=0)
     {
      sum=0.0;
      k=i+BandsPeriod-1;
      oldval=MovingBuffer[i];
      while(k>=i)
        {
         newres=Close[k]-oldval;
         sum+=newres*newres;
         log(str(Time[0]), str(i), str(k), str(newres), str(sum));
         k--;
        }
      deviation=BandsDeviations*MathSqrt(sum/BandsPeriod);
      UpperBuffer[i]=oldval+deviation;
      LowerBuffer[i]=oldval-deviation;
      log(str(MathSqrt(sum/BandsPeriod)))
      log(str(UpperBuffer[i]), str(LowerBuffer[i]));
      i--;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
