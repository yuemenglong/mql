#property  copyright "鑲＄エ"

// #property indicator_chart_window
#property indicator_separate_window
#property indicator_buffers 2

double buffer0[];
double buffer1[];
double buffer2[];

double ma(int cycle, int i, int prev=0) {
   return iMA(NULL, 0, cycle, prev, MODE_SMA, PRICE_CLOSE, i);
}

double ema(int cycle, int i, int prev=0) {
   return iMA(NULL, 0, cycle, prev, MODE_EMA, PRICE_CLOSE, i);
}

int init() {
   SetIndexBuffer(0, buffer0);
   SetIndexBuffer(1, buffer1);
   // SetIndexBuffer(1, buffer1);
   // SetIndexBuffer(2, buffer2);
   return 0;
}

int deinit(){
   return 0;
}

int start() {
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0) return -1;
   if(counted_bars > 0) counted_bars--;
   int limit = Bars - counted_bars;
   
// double  iMAOnArray(
//    double       array[],          // array with data
//    int          total,            // number of elements
//    int          ma_period,        // MA averaging period
//    int          ma_shift,         // MA shift
//    int          ma_method,        // MA averaging method
//    int          shift             // shift
//    );
   int period = 10;
   for(int i=0; i < limit; i++) {
      buffer0[i] = Volume[i];
      double sum = 0;
      for(int j = 0; j < period; j++){
         sum += Volume[i - j];
      }
      buffer1[i] = sum / period;
   }
   return 0;
}
 