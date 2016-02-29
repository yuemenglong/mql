//复盘专用函数库,供供复盘使用.


#import "MTDlib.ex4"
   int getTimeCurrent();//此函数已经弃用,以后会弃用,请用getMTDTimeCurrent()
   int MTDTimeCurrent();//获取当前的时间,代替MT4系统自带的TimeCurrent(),复盘专用.实盘中无效.
   int MTDTimeCurrentIncSTEP();//计算步长在内的当前时间
   
   int MTDTimezone();//当前复盘中外汇等外盘品种所使用的时区
   void MTDlabel(string id="id",string text="",color fontcolor=Lime,int fontsize=20, int x=66, int y=66,int myCorner=0);
   bool isForex(string symbol);//该品种是否是外汇类型
   
   
   int MTDOrderSend(		
         string   symbol,              // symbol
         int      cmd,                 // operation;0,OP_BUY;1,OP_SELL;2,OP_BUYLIMIT;3,OP_SELLLIMIT;4,OP_BUYSTOP;5,OP_SELLSTOP
         double   volume,              // Number of lots.
         double   price,               // price
         int      slippage=0,            // slippage
         double   stoploss=0,            // stop loss   止损价
         double   takeprofit=0,          // take profit 止盈价
         string   comment=NULL,        // comment
         int      magic=0,             // magic number
         datetime expiration=0,        // pending order expiration
         color    arrow_color=clrNONE  // color
   );
   
   
   int MTDOrderCloseAll();//平仓全部
   bool  MTDOrderClose(
         int        ticket,      // ticket
         double     lots,        // volume
         double     price,       // close price
         int        slippage=0,    // slippage
         color      arrow_color=clrNONE  // color
         );
   bool  MTDOrderModify(
      int        ticket,      // ticket
      double     price,       // price
      double     stoploss=0,    // stop loss
      double     takeprofit=0,  // take profit
      datetime   expiration=0,  // expiration
      color      arrow_color=clrNONE  // color
      );   
   bool  MTDOrderDelete(
      int        ticket,      // ticket
      color      arrow_color=clrNONE  // color
      );   
   
   double  MTDBid();
   double  MTDAsk();

   int  MTDOrdersTotal();
   bool  MTDOrderSelect(
      int     index,            // index or order ticket
      int     select,           // flag
      int     pool=MODE_TRADES  // mode
   );
   string MTDOrderSymbol();
   int  MTDOrderTicket();
   int  MTDOrderType();
   double  MTDOrderOpenPrice();
   double  MTDOrderStopLoss();
   double  MTDOrderTakeProfit();   
   double  MTDOrderLots();
   datetime  MTDOrderOpenTime();
   
   double  MTDOrderCommission();   
   double  MTDOrderSwap();    
   double  MTDOrderProfit();  
   string  MTDOrderComment();
   int  MTDOrderMagicNumber();
   datetime  MTDOrderExpiration();
   
   
   
   int  MTDOrdersHistoryTotal();
   double  MTDOrderClosePrice();
   datetime  MTDOrderCloseTime();   
   void  MTDOrderPrint();   
   
   
   double  MTDMarketInfo( 
                        string           symbol,     // symbol 
                        int              type        // information type 
                        );   
   
   bool  MTDIsConnected();
   double  MTDAccountBalance();//---账户余额Returns balance value of the current account.
   double  MTDAccountCredit();//信贷/账户信用点数
   string  MTDAccountCompany();//公司名
   string  MTDAccountCurrency();//基本货币,比如USD
   double  MTDAccountEquity();//净值
   double  MTDAccountFreeMargin();//---可用保证金
   double  MTDAccountFreeMarginCheck(
      string  symbol,     // symbol 
      int     cmd,        // trade operation 
      double  volume      // volume 
      );
   double  MTDAccountFreeMarginMode();
   int  MTDAccountLeverage();//---杠杆倍数
   double  MTDAccountMargin();//---已用保证金
   string  MTDAccountName();//账户姓名
   int  MTDAccountNumber();//账户id
   double  MTDAccountProfit();//账户盈亏
   string  MTDAccountServer();//连接服务器名字,Returns the connected server name.
   int  MTDAccountStopoutLevel();//Returns the value of the Stop Out level.
   int  MTDAccountStopoutMode();//Returns the calculation mode for the Stop Out level.

   
//------------------------以下为未实现函数--------------------------------

   

   int do_debug();
#import
