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
		for(int i = 0; i < 3; i++){
			array_shift(arr){
				iter(arr) = i;
			}
		}
		print(arr);
		array_unshift(arr);
		print(arr);	
	}	
};

setup(Test);
