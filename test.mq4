#property indicator_chart_window

#include "sys/context.mqh"

void print(INT_ARRAY& arr){
	array_each(arr){
		log(str(iter(arr)));
	}
}

class Test : public Context
{
	INT_ARRAY arr;
public:
	virtual void init(){
		for(int i = 1; i < 4; i++){
			array_shift(arr){
				iter(arr) = i;
			}
		}
		print(arr);
		arr.sort();
		print(arr);	
	}	
};

setup(Test);
