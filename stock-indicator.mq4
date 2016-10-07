#property  copyright "股票"

// #property indicator_chart_window
#property indicator_separate_window
#property indicator_buffers 1

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
   
   for(int i=0; i < limit; i++) {
      double gap = ema(6, i) - ema(18, i);
      if(gap > 0){
         buffer0[i] = 1;
      }else if(gap < 0){
         buffer0[i] = -1;
      }else{
         buffer0[i] = 0;
      }
      // buffer0[i] = ema(6, i) - ema(18, i);
      // buffer1[i] = 0;
      // buffer2[i] = ema(108, i);
   }
   return 0;
}
      // if(ma(5, i) > ma(5, i, 1) && ma(10, i) > ma(10, i, 1) && ma(20, i) > ma(20, i, 1) && ma(30, i) > ma(30, i, 1) &&
      //    ma(5, i) > ma(10, i) && ma(10, i) > ma(20, i) && ma(20, i) > ma(30, i)) {
      //    buffer[i] = 1;
      // // } else if(ma(5, i) < ma(5, i, 1) && ma(10, i) < ma(10, i, 1) && ma(20, i) < ma(20, i, 1) && ma(30, i) < ma(30, i, 1) &&
      //    // ma(5, i) < ma(10, i) && ma(10, i) < ma(20, i) && ma(20, i) < ma(30, i)) {
      // } else if(ma(5, i) < ma(5, i, 1) && ma(10, i) < ma(10, i, 1) && ma(20, i) < ma(20, i, 1)){
      //    buffer[i] = -1;
      // } else {
      //    buffer[i] = 0;
      // }

      // if(ma(5, i) > ma(5, i, 1)){
      //    buffer[i]++;
      // }else if(ma(5, i) < ma(5, i, 1)){
      //    buffer[i]--;
      // }

      // if(ma(10, i) > ma(10, i, 1) && ma(10, i) < ma(5, i)){
      //    buffer[i]++;
      // }else if(ma(10, i) < ma(10, i, 1) && ma(10, i) > ma(5, i)){
      //    buffer[i]--;
      // }

      // if(ma(20, i) > ma(20, i, 1) && ma(20, i) < ma(10, i)){
      //    buffer[i]++;
      // }else if(ma(20, i) < ma(20, i, 1) && ma(20, i) > ma(10, i)){
      //    buffer[i]--;
      // }

      // if(ma(30, i) > ma(30, i, 1) && ma(30, i) < ma(20, i)){
      //    buffer[i]++;
      // }else if(ma(30, i) < ma(30, i, 1) && ma(30, i) > ma(20, i)){
      //    buffer[i]--;
      // }

      // if(ma(60, i) > ma(60, i, 1)){
      //    buffer[i]++;
      // }else if(ma(60, i) < ma(60, i, 1)){
      //    buffer[i]--;
      // }

      // if(ma(120, i) > ma(120, i, 1)){
      //    buffer[i]++;
      // }else if(ma(120, i) < ma(120, i, 1)){
      //    buffer[i]--;
      // }

      // if(ma(240, i) > ma(240, i, 1)){
      //    buffer[i]++;
      // }else if(ma(240, i) < ma(240, i, 1)){
      //    buffer[i]--;
      // }