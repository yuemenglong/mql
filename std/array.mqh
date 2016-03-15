#include "../kit/log.mqh";

class ArrayItem
{
public:
	virtual bool operator ==(ArrayItem& t){
		return false;
	}
};

#define ARRAY_SIZE 512

#define ARRAY_DEFINE(T, NAME) \
struct NAME \
{ \
	int _head; \
	int _tail; \
	int _capacity; \
	T _array[ARRAY_SIZE]; \
	\
	NAME(); \
	void remove_head(int idx); \
	void remove_tail(int idx); \
	void remove(int idx); \
	void fix(); \
	int size(); \
	int capacity(); \
	bool full(); \
	int pos(int idx); \
	bool push_back(); \
	bool pop_back(); \
	bool push_front(); \
	bool pop_front(); \
	int find(T& t, int from = 0); \
	void sort(); \
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
bool NAME::push_back(){ \
	if(full()){ \
		return false; \
	} \
	_tail++; \
	fix(); \	
	return true; \
} \
bool NAME::pop_back(){ \
	if(size() == 0){ \
		return false; \
	} \
	_tail--; \
	fix(); \
	return true; \
} \
bool NAME::push_front(){ \
	if(full()){ \
		return false; \
	} \
	_head--; \
	fix(); \
	return true; \
} \
bool NAME::pop_front(){ \
	if(size() == 0){ \
		return false; \	
	} \
	_head++; \
	fix(); \
	return true; \
} \
int NAME::find(T& t, int from){ \
	for(int i = from; i < size(); i++){ \
		if(_array[pos(i)] == t){ \
			return i; \
		} \
	} \
	return -1; \
} \
void NAME::remove_head(int idx){ \
	T tmp[ARRAY_SIZE]; \
	ArrayCopy(tmp, _array, 0, _head + 1, idx); \
	ArrayCopy(_array, tmp, _head + 2, 0, idx); \
	_head++; \
	fix(); \
} \
void NAME::remove_tail(int idx){ \
	T tmp[ARRAY_SIZE]; \
	int pos = pos(idx); \
	ArrayCopy(tmp, _array, 0, pos + 1, size() - idx - 1); \
	ArrayCopy(_array, tmp, pos, 0, size() - idx - 1); \
	_tail--; \
	fix(); \
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
void NAME::sort(){ \
	if(_head >= _tail){ \
		T tmp[ARRAY_SIZE]; \
		int size = size(); \
		ArrayCopy(tmp, _array, 0, _head+1, ARRAY_SIZE-_head-1); \
		ArrayCopy(tmp, _array, ARRAY_SIZE-_head-1, 0, _tail); \
		ArrayCopy(_array, tmp, 1, 0, size); \
		_head = 0; \
		_tail = size + 1; \
	} \
	ArraySort(_array, size(), _head+1); \
} \

#define array_front(array) \
(array._array[array.pos(0)])

#define array_back(array) \
(array._array[array.pos(array.size() - 1)])

#define array_get(array, idx) \
(array._array[array.pos(idx)])

#define iter(array) \
(array._array[array.pos(__IDX)])

#define array_each(array) \
for(int __IDX = 0; __IDX < array.size(); __IDX++)

#define array_push(array) \
for(int __IDX = array.size(), __ONCE = 1; \
	__ONCE && array.push_back(); \
	__ONCE--)

#define array_pop(array) \
do{array.pop_back();}while(0)

#define array_shift(array) \
for(int __IDX = 0, __ONCE = 1; \
	__ONCE && array.push_front(); \
	__ONCE--)

#define array_unshift(array) \
do{array.pop_front();}while(0)	


ARRAY_DEFINE(int, INT_ARRAY);
ARRAY_DEFINE(string, STR_ARRAY);