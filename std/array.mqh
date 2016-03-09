#define ARRAY_SIZE 128

#define ARRAY_DEFINE(T, NAME) \
class NAME \
{ \
private: \
	int _head; \
	int _tail; \
	int _capacity; \
	T _arr[ARRAY_SIZE]; \
public: \
	NAME(); \
	int size(); \
	void push_back(T t); \
	T pop_back(); \
	void push_front(T t); \
	T pop_front(); \
	T operator [] (const int idx); \
	void remove(int idx, int count = 1); \
	void resize();
}; \
NAME::NAME(){ \
	_capacity = ARRAY_SIZE; \
	_head = 0; \
	_tail = 1; \
} \
int NAME::size(){ \
	return _tail - _head - 1; \
} \
void NAME::push_back(T t){ \
	if(_tail >= _capacity){
		resize();
	}
	_arr[_tail] = t; \
	_tail++; \
} \
T NAME::pop_back(){ \
	_tail--; \
	return _arr[_tail]; \
} \
void NAME::push_front(T t){ \
	if(_head < 0){
		resize();
	}
	_arr[_head] = t; \
	_head--; \
} \
T NAME::pop_front(){ \
	_head++; \
	return _arr[_head]; \
} \
T NAME::operator[](int idx){ \
	return _arr[_head + idx + 1]; \
} \
void NAME::remove(int idx, int count){ \
	for(int i = _head + idx + 1, t = 0; t < size() - count; i++, t++){ \
		_arr[i] = _arr[i + count]; \
	} \
	_tail -= count; \
} \
void NAME::resize(){ \
	if(size >= _capacity / 2){
		_capacity *= 2;
	}
	int dst = _capacity / 4;
	for(int i = _head + 1, t = 0; t < size() - count; i++, t++){ \
		_arr[i] = _arr[i + count]; \
	} \
	_tail -= count; \
} \
