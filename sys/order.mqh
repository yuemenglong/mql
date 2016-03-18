class Order : public ArrayItem
{
public:
	int _ticket;
	int _op;
	datetime _pending_time;
	double _pending_price;
	double _stop_loss;
	double _volumn;

	Order(int ticket){
		_ticket = ticket;
	}
	Order(int type, double price, double volumn){
		_op = type;
		_pending_price = price;
		_volumn = volumn;
	}
	void set_pending_price(double price){
		_pending_price = price;
	}
	void set_stop_loss(double stop_loss){
		_stop_loss = stop_loss;
	}
	void set_volumn(double volumn){
		_volumn = volumn;
	}
	void send(){
		_ticket = MTDOrderSend(Symbol(), _op, 
			_volumn, _pending_price, 0, _stop_loss);
		_pending_time = Time[0];
	}
	int ticket(){
		return _ticket;	
	}
	bool select(){
		// MTDOrderSelect(SELECT_BY_TICKET, _ticket);
		int total = MTDOrdersTotal();
		for(int i = 0; i < total; i++){
			MTDOrderSelect(i, SELECT_BY_POS);
			if(MTDOrderTicket() == _ticket){
				return true;
			}
		}
		return false;
	}
	bool select_history(){
		int total = MTDOrdersHistoryTotal();
		for(int i=0;i < total; i++){
			MTDOrderSelect(i, SELECT_BY_POS, MODE_HISTORY);
			if(MTDOrderTicket() == _ticket){
				return true;
			}
		}
		return false;
	}
	int order_type(){
		if(!select() && !select_history()){
			return -1;
		}
		return MTDOrderType();
	}
	double open_price(){
		if(!select() && !select_history()){
			return -1;
		}
		return MTDOrderOpenPrice();
	}
	datetime open_time(){
		if(!select() && !select_history()){
			return -1;
		}
		return MTDOrderOpenTime();
	}
	double volumn(){
		if(!select() && !select_history()){
			return -1;
		}
		return MTDOrderLots();
	}
	
	virtual bool eq(Order* order){
		if(_ticket == order._ticket){
			return true;
		}
		return false;
	}
};

