#include "../kit/log.mqh";
#define ARRAY_SIZE 512

#define ARRAY_DEFINE(T, NAME) \
class NAME \
{ \
private: \
	int _head; \
	int _tail; \
	int _capacity; \
	T _arr[ARRAY_SIZE]; \
	void remove_head(int idx); \
	void remove_tail(int idx); \
	void fix(); \
public: \
	NAME(); \
	int size(); \
	int capacity(); \
	bool full(); \
	int pos(int idx); \
	void push_back(T t); \
	void push_back(T& t[]); \
	T pop_back(); \
	void push_front(T t); \
	T pop_front(); \
	T operator [] (const int idx); \
	void remove(int idx); \
	void resize(); \
}; \
NAME::NAME(){ \
	_capacity = ARRAY_SIZE; \
	_head = 0; \
	_tail = 1; \
} \
bool NAME::full(){ \
	return size() == _capacity - 1; \
} \
int NAME::size(){ \
	return (_capacity + _tail - _head - 1) % _capacity ; \
} \
int NAME::capacity(){ \
	return _capacity; \
} \
int NAME::pos(int idx){ \
	return (_head + 1 + idx) % _capacity; \
} \
void NAME::fix(){ \
	_head = (_capacity + _head) % _capacity; \
	_tail = (_capacity + _tail) % _capacity; \
} \
void NAME::push_back(T t){ \
	if(full()){ \
		resize(); \
	} \
	_arr[_tail] = t; \
	_tail++; \
	fix(); \	
} \
void NAME::push_back(T& t[]){ \
	for(int i = 0; i < ArraySize(t); i++){ \
		push_back(t[i]); \
	} \
} \
T NAME::pop_back(){ \
	if(size() == 0){ \
		return T(); \
	} \
	_tail--; \
	fix(); \
	return _arr[_tail]; \
} \
void NAME::push_front(T t){ \
	if(full()){ \
		resize(); \
	} \
	_arr[_head] = t; \
	_head--; \
	fix(); \
} \
T NAME::pop_front(){ \
	if(size() == 0){ \
		return T(); \
	} \
	_head++; \
	fix(); \
	return _arr[_head]; \
} \
T NAME::operator[](int idx){ \
	return _arr[pos(idx)]; \
} \
void NAME::remove(int idx){ \
	int pos = pos(idx); \
	if(_tail <= _head && pos < _tail){ \
		remove_tail(idx); \
	} else if(_tail <= _head && pos > _head){ \
		remove_head(idx); \
	} else if(pos < (_head + _tail) / 2){ \
		remove_head(idx); \
	} else{ \
		remove_tail(idx); \
	} \
} \
void NAME::remove_head(int idx){ \
	int pos = pos(idx); \
	for(int i = pos; i > _head + 1; i--){ \
		_arr[i] = _arr[i - 1]; \
	} \
	_head++; \
	fix(); \
} \
void NAME::remove_tail(int idx){ \
	int pos = pos(idx); \
	for(int i = pos; i < _tail - 1; i++){ \
		_arr[i] = _arr[i + 1]; \
	} \
	_tail--; \
	fix(); \
} \
void NAME::resize(){ \
	int ret = ArrayResize(_arr, _capacity * 2); \
	log("resize", str(ret)); \
	if(_tail > _head){ \
		return; \
	} \
	ArrayCopy(_arr, _arr, _capacity, 0, _tail); \
	_tail = _head + size() + 1; \
	_capacity *= 2; \
} \
