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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Order : public HashValue
{
private:
    int _ticket;
    int _operation;
    double _volumn;
    double _price;

    datetime _open_time;
public:
	Order(int operation, double volumn, double price);
	~Order();

    void send();
    void close(double price);
    bool select();

    int type();
    double lots();

    int ticket();
    double price();
    int operation();

    Order* clone();
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Order::Order(int operation, double volumn, double price)
{
    price = ((int)(price * 100000))/100000.0;
    _operation = operation;
    _volumn = volumn;
    _price = price;
    _ticket = 0;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Order::~Order()
{
}
//+------------------------------------------------------------------+
void Order::send()
{
    MTDOrderSend(Symbol(), _operation, _volumn, _price);
    _open_time = MTDTimeCurrent();
}

void Order::close(double price)
{
    if(select())
    {
        MTDOrderClose(_ticket, _volumn, price);
    }
}

Order* Order::clone()
{
    return new Order(_operation, _volumn, _price);
}

bool Order::select()
{
    if(_ticket != 0)
    {
        MTDOrderSelect(_ticket, SELECT_BY_TICKET);
        return true;
    }
    int total = MTDOrdersTotal();
    for(int i = 0; i < total; i++)
    {
        MTDOrderSelect(i, SELECT_BY_POS);
        double price = MTDOrderOpenPrice();
        datetime time = MTDOrderOpenTime();
        if(_price == price && _open_time == time)
        {
            _ticket = MTDOrderTicket();
            return true;
        }
    }
    return false;
}

double Order::lots()
{
    if(select()){
        return MTDOrderLots();
    }
    return 0;
}

int Order::type()
{
    if(select()){
        return MTDOrderType();
    }
    return -1;
}

int Order::ticket()
{
    return _ticket;
}

double Order::price()
{
    return _price;
}

int Order::operation()
{
    return _operation;
}