//+------------------------------------------------------------------+
//|                                                        order.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict

#include <MTDinc.mqh>;
#include "../kit/log.mqh";
#include "../kit/hash.mqh";
#include "order.mqh";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class OrderMonitor 
{
private:
    Hash _orders;
public:
	OrderMonitor();
	~OrderMonitor();

    void add(Order* order);
    void check(double last_price);
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
OrderMonitor::OrderMonitor()
{
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
OrderMonitor::~OrderMonitor()
{
}
//+------------------------------------------------------------------+
void OrderMonitor::add(Order* order)
{
    _orders.hPut(str(order.price()), order);
}

void OrderMonitor::check(double close_proce)
{
	Hash rm;
	Hash add;
    HashLoop loop(&_orders);
    for ( ; loop.hasNext() ; loop.next())
    {
        Order* order = loop.val();
        if(order.type() == order.operation())
        {
        	continue;
        }
        if(order.operation() == OP_BUYSTOP && close_proce < order.price())
        {
        	log("OP_BUYSTOP");
        	order.close(close_proce);
        	// order.send();
        }
        else if(order.operation() == OP_SELLSTOP && close_proce > order.price())
        {
        	log("OP_SELLSTOP");
        	order.close(close_proce);
        	// order.send();
        }
    }
 
}